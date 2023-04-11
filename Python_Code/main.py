import logging
import coloredlogs
from Core.globals import EXIT_APP_EVENT
from SB3.RL_algorithm import run_algorithm
from DrlPlatform import UdpServer

if __name__ == "__main__":
    coloredlogs.install(level="INFO")
    logging.getLogger().setLevel(logging.INFO)
    logger = logging.getLogger(__name__)
    # Establish server for env connection
    env_server = UdpServer(
        server_host="192.168.10.192",
        server_port=16389,
        client_host="192.168.10.181",  #REPLACE WITH IP FROM PXI
        client_port=16385,
        package_timeout=30.0,
        max_package_size=4096
    )
    # Start inference agent
    try:
        logger.info("Starting environment server. Waiting for connection...")
        env_server.start_server()
        run_algorithm(env_server)
    except KeyboardInterrupt:
        EXIT_APP_EVENT.set()
    except Exception as err:
        logger.error("Received error, %s", str(err))
        EXIT_APP_EVENT.set()
        raise err
    finally:
        env_server.close_server()
