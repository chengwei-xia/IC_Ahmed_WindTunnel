.. _Experiment Manual:

Experiment Manual
=================

This section demonstrates the procedures of conducting this wind tunnel experiment properly, including cable connection from Ahmed body to PXI, sensors & actuators taring, and how to run the experiment.

.. _Cable Connection:

Cable Connection
----------------

For the cables on Ahmed body side, they need to be arranged properly to go through the four legs of Ahmed body. The arrangement is presented in the following list and picture.

- Front Left: actuation cables and one encoder BNC cable.
- Front Right: one ESP cable, one linear screw cable, and encoder digital cables.
- Back Left: three Endevco cables and one reference pressure tube.
- Back Right: four Endevco cables.
- Middle: one force balance cable.

.. image:: /_static/img/WT_Cable.png
   :align: center
   :scale: 40%

On the PXI & PC side, cables are mostly connected via the BNC-2110 panel, and details are listed in the following subsections.

.. image:: /_static/img/PXI_Cables.png
   :align: center

**Encoder**

Encoders are connected to PXI via the BNC-2110 connector panel. The ports correspond to the following:

- VDD -- Black wire -- 5V
- Vss -- Green wire -- Digital Ground
- CLK -- Blue wire  -- PFI13 (CTR1 OUT)
- CSn -- BNC cable  -- PFI12 (CTR0 OUT)
- DO  -- PicoBlade wires -- P0.0 - P0.3 (refer to Labview code)

**Flaps & Power Box**

The actuators on the flaps are connected to PXI via a power box. There are four AO signals from PXI to the power box as actuation. Another 8 AI signals are from the power box to PXI for measuring voltages. Connection & ports are listed below:

- 4 * AO -- BNC cable -- PXI:AO0-AO3
- 8 * AI -- BNC cable -- PXI:AI9-AI16

**ESP**

ESP is connected to an external power supply via power cables and to the host PC via a network cable.

**Endevco**

Endevco cables are connected to amplifiers with D-connectors first, and then connected to PXI as AI signals:

- 8 * AI -- BNC cable -- PXI:AI0-AI8

**Force Balance**

The force balance is connected to PXI with an independent card. It is connected to PXI slot 5 in the current use.

**Linear Screw**

Linear screws are driven by DC motors, and the power cables of these DC motors are connected to two chips that can switch between signals. The chips are connected to two counters on the BNC-2110 to generate PWM signals.

.. note::

   In the Labview code, the port number and slot for connection may be changed over time. Please check the channel initialization part for each sensor/actuator to make sure you use the correct ports or slots.


.. _Taring:

Taring
-------

**Flap**

Open ``Flap_Position.vi`` **check this name** and do following steps to tare the flaps:

- Input zeros in the vector ``Zero Angles``
- Run ``Flap_Position.vi`` with reading mode and manually move the flaps to zero degrees (with a calibrator). Read current measurements.
- Stop ``Flap_Position.vi`` and input the measurements from the last step as offsets.
- Run ``Flap_Position.vi`` with calibration mode to compensate angle offsets.

.. note::

   There are **only two counters** available for taring the angle of flaps. Therefore, the counters have to be switched between four linear screws. Every time, the channels for one linear screw are activated. After tuning, they have to be **deactivated** to give space for the next one. The ``Clear Task`` function in Labview **WILL NOT** deactivate the physical channel. In this code, a ``Tristate`` function is used after each manipulation to deactivate the physical channel.

**ESP**

Open ``ESP_Full_State.vi`` and do the following steps to tare the pressure measurements:

- Check there is no disturbance during taring the ESP.
- Run ``ESP_Full_State.vi`` and click "zero".
- Wait for around 30s and click "stream" to see whether it is tared.

**Endevco**

Endevco pressure transducers are tared via amplifiers, do the following steps on the amplifier panel:

- Select a channel by pressing the button beside the channel display.
- Select function "Zero"
- Change mode to "On" by pressing the "up" button, and wait for a few seconds.

**Force Balance**

Open ``Target_Main.vi`` and switch to the force balance page. Press "Press to Tare" button and check whether the readings are tared. 

.. note::

   **NOT Recommended** If tare the flaps with the body upside down, there will still be an offset on flaps due to gravity.

.. _Wind Tunnel Installation:

Wind Tunnel Installation
------------------------

The experiment has been set up in wind tunnel T2 at Imperial College London.
The floor of the wind tunnel is lifted up for **45 mm** to remove the boundary layer from the contraction section of the tunnel. And a leading edge is installed at the front of the lifted floor to avoid flow separation. The Ahmed body sits on a holding plate (a round wooden plate) mounted on the tunnel floor.

.. note::

   The boundary layer thickness measures **47 mm** at around **800 mm* downstream from the contraction section, and the thickness is believed to be smaller than **45 mm** at the contraction. So we used **45 mm** standard ``mini-tech`` to support the floor, which greatly reduced the installation complexity. The boundary layer thickness on the lifted floor needs to be measured again in the future.

During the installation, the Ahmed body is placed on the floor first, and the force balance is installed underneath the floor. The mounting side of the force balance is screwed to the bottom of the holding plate first. Then, the Ahmed body should be lifted up for around but less than **28 mm**, and screw the tool side of the force balance to the legs via a tool plate.

The pictures of Ahmed body and the force balance installation are shown below.

.. image:: /_static/img/Ahmed.png
   :align: center

.. image:: /_static/img/FB_install.png
   :align: center

.. _Code Running:

Code & Running
--------------

Labview scripts are saved in ``Trial_OnlyMicrophones.lvproj`` project **Name May be Changed**. Open this project and check the connection with PXI before running. Essential Python scripts for conducting are ``main.py``, ``SB3\RL_algorithm.py`` and ``Core\LABVIEW_Environment.py``.

.. note::

   Remember to tare **Endevco pressure sensors**, **ESP pressure scanner** and **ATI force balance** before running wind tunnel or any code for the actual experiment. See :ref:`Taring <Taring>` for how to tare these measurements.

**Baseline Flow (without control)**

- Run the Labview on the wind tunnel console and check the target wind speed.
- Run ``Target_Main.vi`` to activate the data acquisition loops, with actuations set to zero.
- Run ``Host_Main.vi`` to visualise and save data. 

.. note::
  
   Check saving path and file names in ``Host_Main.vi``.

.. note::
  
   The actual wind speed is usually not consistent with the target speed. Check the wind speed on FCO and adjust the target speed.

**RL Training**

- Check all the parameters and settings in ``SB3\RL_algorithm.py``. (Environment, ``MODE`` and ``savedir`` etc.)
- Run the wind tunnel and wait for wind speed to settle down.
- Run ``Target_Main.vi``.
- Run ``main.py`` to activate RL-environment interaction.
- Run ``Host_Main.vi``.

.. note::
  
   If the training needs to be restarted, change the ``MODE`` to "restart" and use a correct loading path in ``model = XXX.load``. Change the log name to clarify "restart".

**RL Evaluation**

- Change settings in ``SB3\RL_algorithm.py``. ``MODE`` to "infer".
- Run the wind tunnel and wait for wind speed to settle down.
- Run ``Target_Main.vi``.
- Run ``main.py``.
- Run ``Host_Main.vi``.

.. note::

   Usually a baseline flow test is conducted before and after evaluation to ensure there is no sensor drifting effect, or to use two baseline data to compensate sensor drifting.
