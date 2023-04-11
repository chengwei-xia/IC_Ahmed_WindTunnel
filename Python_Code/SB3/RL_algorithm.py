import logging
import os
import gym
import argparse

from stable_baselines3.common.callbacks import BaseCallback, CheckpointCallback, CallbackList
from stable_baselines3.common.vec_env import DummyVecEnv, VecFrameStack, SubprocVecEnv
from stable_baselines3.ppo.ppo import PPO

from DrlPlatform.Models.abstract_server import AbstractServer
from Core.globals import EXIT_APP_EVENT

from sb3_contrib import TQC, RecurrentPPO
import gym.envs
import numpy as np

class CustomCallback(BaseCallback):
    """
    A custom callback that derives from ``BaseCallback``.

    :param verbose: (int) Verbosity level 0: not output 1: info 2: debug
    """
    def __init__(self, verbose=0):
        super(CustomCallback, self).__init__(verbose)

    def _on_training_start(self) -> None:
        """
        This method is called before the first rollout starts.
        """
        pass

    def _on_rollout_start(self) -> None:
        """
        A rollout is the collection of environment interaction
        using the current policy.
        This event is triggered before collecting new samples.
        """
        pass

    def _on_step(self) -> bool:
        """
        This method will be called by the model after each call to `env.step()`.

        For child callback (of an `EventCallback`), this will be called
        when the event is triggered.

        :return: (bool) If the callback returns False, training is aborted early.
        """
        return True

    def _on_rollout_end(self) -> None:
        """
        This event is triggered before updating the policy.
        """
        logger= logging.getLogger(__name__)
        logger.error("ROLLOUT END")
        self.training_env.reset() # type: ignore

    def _on_training_end(self) -> None:
        """
        This event is triggered before exiting the `learn()` method.
        """
        logger= logging.getLogger(__name__)
        logger.error("TRAINING END")

MODE="train"
OBSERVATION_TYPE="All"
ALGORITHM="PPO"
MODELS_ROOT = f"./Models/"
LOGS_ROOT = f"./Logs"

if not os.path.exists(MODELS_ROOT):
    raise ValueError("Models root directory does not exist")

if not os.path.exists(LOGS_ROOT):
    raise ValueError("Logs root directory does not exist")

def run_algorithm(server: AbstractServer):
    logger = logging.getLogger(__name__)


    if OBSERVATION_TYPE == "ForceBalance":
        gym.envs.register(
            id='AhmedBody_Force-v0',
            entry_point='Case.LABVIEW_Environment:AhmedBody_Force',
            max_episode_steps=512,
            reward_threshold=512,

        )

        env: gym.Env = gym.make('AhmedBody_Force-v0') #type: ignore

    if OBSERVATION_TYPE == "Pressure":
        gym.envs.register(
            id='AhmedBody_Pressure-v0',
            entry_point='Case.LABVIEW_Environment:AhmedBody_Pressure',
            max_episode_steps=512,
            reward_threshold=512,

        )

        env: gym.Env = gym.make('AhmedBody_Pressure-v0')  # type: ignore

    if OBSERVATION_TYPE == "All":
        gym.envs.register(
            id='AhmedBody_AllObservations-v0',
            entry_point='Case.LABVIEW_Environment:AhmedBody_AllObservations',
            max_episode_steps=2048,
        )

        env: gym.Env = gym.make('AhmedBody_AllObservations-v0')  # type: ignore

    env.env.env_server = server #type: ignore
    if ALGORITHM == "TQC":
        ap = argparse.ArgumentParser()
        ap.add_argument("-s", "--savedir", required=False,
                        help="Directory into which to save the NN. Defaults to 'saver_data'.", type=str,
                        default='saver_data/TQC_3')

        args = vars(ap.parse_args())
        savedir = args["savedir"]

        config = {}

        config["learning_rate"] = 2.5e-4
        config["learning_starts"] = 0
        config["batch_size"] = 128

        config["tau"] = 5e-3
        config["gamma"] = 0.99
        config["train_freq"] = 1
        config["target_update_interval"] = 1
        config["gradient_steps"] = 1

        config["buffer_size"] = int(10e5)
        config["optimize_memory_usage"] = False

        config["ent_coef"] = "auto_0.1"
        config["target_entropy"] = "auto"
        config["top_quantiles_to_drop_per_net"] = 2
        config["device"] = "cpu"
        policy_kwargs = dict(net_arch=dict(pi=[64,64], qf=[64,64]))
        #env = DummyVecEnv([lambda: gym.make('AhmedBody_AllObservations-v0')])
        #env = VecFrameStack(env, n_stack=27)
        model = TQC('MlpPolicy', env, policy_kwargs=policy_kwargs, tensorboard_log=savedir, **config)

        if MODE == "train":
            checkpoint_callback = CheckpointCallback(
                save_freq=max(4096, 1),
                save_path=savedir)
            model.learn(1500000, callback=[checkpoint_callback], log_interval=1)
        elif MODE == "restart":
            checkpoint_callback = CheckpointCallback(
                save_freq=max(4096, 1),
                save_path=savedir)
            model = TQC.load("./saver_data/TQC_3/rl_model_131072_steps.zip", env=env)
            model.learn(1500000, callback=[checkpoint_callback], log_interval=1)

        elif MODE == "infer":
            # model = model.load("./Models/IPD_OL/PPO_2/rl_model_200704_steps.zip")
            logger.warning("Operate the Ahmed Body once the NN is fully trained")
            obs = env.reset()
            while True:
                action, _state = model.predict(obs, deterministic=True)
                logger.warning(f"Action: {action}")
                obs, reward, done, info = env.step(action)
                logger.info(f"Observation: {obs}")
                if done:
                    obs = env.reset()
        else:
            logger.error(f"unknown mode: {MODE}")
    elif ALGORITHM == "PPO":
        if MODE=="train":
            model = PPO('MlpPolicy',
                        env,
                        verbose=1,
                        tensorboard_log=f"{LOGS_ROOT}/IPD_OL/PPO_8",
                        n_steps=2048,
                        # This is the number of steps of each episode. Time per episode = n_steps / frequency
                        batch_size=64,
                        gae_lambda=0.95,
                        gamma=0.99,
                        n_epochs=20,
                        # This is the number of updates to compute policy gradient and update to the policy
                        ent_coef=0.0,
                        learning_rate=2.5e-4,
                        clip_range=0.2,
                        device="cpu",
                        policy_kwargs=dict(net_arch=dict(pi=[512,512], vf=[512,512]))
                        )
            iteration = 0
            TOTAL_EPISODES=4500
            TIMESTEPS=4_500_000
            while not EXIT_APP_EVENT.is_set():
                iteration += 1
                rollout_callback = CustomCallback()
                checkpoint_callback = CheckpointCallback(save_freq=4096, save_path=f'{MODELS_ROOT}/IPD_OL/PPO_8')
                callback = CallbackList([checkpoint_callback, rollout_callback])
                model.learn(total_timesteps=TIMESTEPS, callback = callback, tb_log_name = f"PPO_8", reset_num_timesteps=True)
                if iteration == TOTAL_EPISODES:
                    break
        elif MODE=="restart":
            iteration = 0
            TOTAL_EPISODES=4500
            TIMESTEPS=4_500_000
            while not EXIT_APP_EVENT.is_set():
                iteration += 1
                rollout_callback = CustomCallback()
                checkpoint_callback = CheckpointCallback(save_freq=4096, save_path=f'{MODELS_ROOT}/IPD_OL/PPO_8_restart')
                callback = CallbackList([checkpoint_callback, rollout_callback])
                model = PPO.load("./Models/IPD_OL/PPO_8/rl_model_40960_steps.zip", env = env)
                model.learn(total_timesteps=TIMESTEPS, callback = callback, tb_log_name = f"PPO_8_restart", reset_num_timesteps=True)
                if iteration == TOTAL_EPISODES:
                    break
        elif MODE == "infer":

            model = PPO.load("./Models/IPD_OL/PPO_4_restart3/rl_model_135168_steps.zip")
            logger.warning("Operate the Ahmed Body once the NN is fully trained")
            obs = env.reset()
            while True:
                action, _state = model.predict(obs, deterministic=True)
                logger.warning(f"Action: {action}")
                obs, reward, done, info = env.step(action)
                logger.info(f"Observation: {obs}")
                if done:
                    obs = env.reset()

    elif ALGORITHM == "RNN_PPO":
         if MODE == "train":
            model = RecurrentPPO('MlpLstmPolicy',
                        env,
                        verbose=1,
                        tensorboard_log=f"{LOGS_ROOT}/IPD_OL/RNN_PPO_2",
                        n_steps=2048,
                        # This is the number of steps of each episode. Time per episode = n_steps / frequency
                        batch_size=64,
                        gae_lambda=0.95,
                        gamma=0.99,
                        n_epochs=10,
                        # This is the number of updates to compute policy gradient and update to the policy
                        ent_coef=0.0,
                        learning_rate=2.5e-4,
                        clip_range=0.2,
                        device="cpu",
                        policy_kwargs=dict(lstm_hidden_size=32, n_lstm_layers=2, net_arch=dict(pi=[256,256], vf=[256,256]))
                        )
            iteration = 0
            TOTAL_EPISODES = 4500
            TIMESTEPS = 4_500_000
            while not EXIT_APP_EVENT.is_set():
                iteration += 1
                rollout_callback = CustomCallback()
                checkpoint_callback = CheckpointCallback(save_freq=4096, save_path=f'{MODELS_ROOT}/IPD_OL/RNN_PPO_2')
                callback = CallbackList([checkpoint_callback, rollout_callback])
                model.learn(total_timesteps=TIMESTEPS, callback=callback, tb_log_name=f"RNN_PPO_2",
                            reset_num_timesteps=True)
                if iteration == TOTAL_EPISODES:
                    break
         elif MODE == "restart":
            iteration = 0
            TOTAL_EPISODES = 4500
            TIMESTEPS = 4_500_000
            while not EXIT_APP_EVENT.is_set():
                iteration += 1
                rollout_callback = CustomCallback()
                checkpoint_callback = CheckpointCallback(save_freq=4096,
                                                         save_path=f'{MODELS_ROOT}/IPD_OL/RNN_PPO_2_restart6')
                callback = CallbackList([checkpoint_callback, rollout_callback])
                model = RecurrentPPO.load("./Models/IPD_OL/RNN_PPO_2_restart5/rl_model_16384_steps.zip", env=env)
                model.learn(total_timesteps=TIMESTEPS, callback=callback, tb_log_name=f"PPO",
                            reset_num_timesteps=True)
                if iteration == TOTAL_EPISODES:
                    break
         elif MODE == "infer":

            model = RecurrentPPO.load("./Models/IPD_OL/RNN_PPO_2_restart6/rl_model_61440_steps.zip")
            logger.warning("Operate the Ahmed Body once the NN is fully trained")
            obs = env.reset()

            lstm_states = None
            num_envs = 1
            episode_starts = np.ones((num_envs,), dtype = bool)

            while True:
                action, lstm_states = model.predict(obs, state = lstm_states, episode_start = episode_starts, deterministic=True)
                logger.warning(f"Action: {action}")
                obs, reward, done, info = env.step(action)
                episode_starts = done
                logger.info(f"Observation: {obs}")

                if done:
                    obs = env.reset()
    else:
        logger.error(f"unknown mode: {MODE}")
