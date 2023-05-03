.. _Hardware Setup:

Hardware Setup
==============

This section covers all the hardware setup for the experiment, including sensor cabling, basic information of each device, etc. 

The picture below shows the general setup in T1 Imperial College London, August 2022, including PXI, PC, wind tunnel and the Ahmed body.

.. image:: /_static/img/HardwareSetup_Mar2023.png
   :align: center
   :scale: 60%

.. _Encoder:

Encoder
-------

Four Avago AEAT-6012 encoders are used for angle measurements of four flaps. There are five pins on the output end of the encoder, as illustrated in the figure below, functioning power supply, clock and digital output, etc.

.. image:: /_static/img/Encoder_connector.png
   :align: center
   :scale: 80%

A circuit board is designed as the figure below, connecting all the encoders for convenience. The power supply ``VDD`` and ``Vss`` , chip selection ``CSn`` and clock signal ``CLK`` are shared on the circuit board. Four digital outputs are connected independently.

.. image:: /_static/img/Encoder_connection.png
   :align: center
   :scale: 80%

The circuit box is sealed in a metal box to avoid electromagnetic interference. The output connection from circuit box to PXI (via BNC-2110 connector) can be referred to ref:`Cable Connection <Cable Connection>`

.. _Flaps:

Flaps & Power Box
-----------------

A power box was designed to connect the flaps to PXI, together with a function of measuring voltages applied to the flaps, as shown in the figure.

.. image:: /_static/img/PowerBox.png
   :align: center
   :scale: 60%

The dimensions of the flaps used in Brackston et al. 2016 (``flap set 1``) are recorded as:

- Left/Right: **151.38mm** in width and **26mm** in length
- Top/Bottom: **203.38mm** in width and **18mm** in length 

In order to enhance the flow modulation effect, the flaps are lengthened to *flap length*/*body width or height* = 0.2 (``flap set 2``), corresponding to:

- Left/Right: **43mm** in length
- Top/Bottom: **32mm** in length

However, after testing in March 2023, these longer flaps suppressed the bistability completely, which indicates that they were longer than required. Therefore, the setup now is using ``flap set 1`` instead.

.. note::

   If the flaps are replaced when the body has been installed in the wind tunnel, the screws on the bottom flap are not accessible. The force balance needs to be removed and the body needs to be lifted up if you want to replace the bottom flap. **Replacing flaps in advance is recommended.**

.. _ESP:

Pressure Taps (ESP)
-------------------

ESP pressure scanner is combined with a microDAQ device. You have to connect 64 pressure tubes from the body to the pressure scanner, and then connect the scanner to microDAQ. The microDAQ is connected to the host PC with a special cable, which has an end with network and power connectors.

Once the ESP and microDAQ are set up successfully, you can see a blue light twinkling on the microDAQ box.

**Add pictures here for connection setup**

.. warning::

   The microDAQ **DOES NOT** allow hot-plugged to the power supply, and the voltage input is limited. You **MUST** connect the cable to power supply when the power supply is **POWERED OFF**. Then, start with the power supply to max current and **MIN VOLTAGE**. Tune the voltage gradually with **12V LIMITATION**.

.. note::

   Please keep the microDAQ working for 0.5~1 hour to **warm up** before using it. Otherwise the measurements will be drifting over time.

.. note::

   Keep the pressure scanner in a horizontal position to avoid dirt going into the taps. For further instructions and guides, please refer to *A practical note on pressure scanner Chell microDAQ*.


.. _Endevco:

Pressure Transducers (Endevco)
------------------------------

There are 8 Endevco Pressure Transducers installed on the back surface of the Ahmed body. One of the sensors was broken (No.5) and 7 sensors are used in this experiment.

On the Endevco sensor side, a circular connector of 5 pins is used. ``712 Series, Manufacturer: Binder, RS Part No: 9904130005/9904140005.`` On the amplifier side, a D-connector of 9 pins is used. ``MH Connectors 9 Way D-sub Connector``. Cables were made to connect sensor side to the amplifiers. The wire connection ``Type 1`` on the cable heads of two ends is shown in the pictures below.

.. image:: /_static/img/Edv_wire.png
   :align: center
   :scale: 50%

.. warning::

   The wires inside the connectors are very thin and vulnerable. **Be careful** when connecting or moving the cables.

The cabling on the sensor side is presented in the figure below. Four wires connect four ends of the Wheatstone bridge (colour matched), and the cable shield is connected to sensor cable.

.. image:: /_static/img/Edv_SensorSide.png
   :align: center
   :scale: 40%

The cabling and the functions of the pins on the D-Connector on the amplifier side are shown in the figure below. 

.. image:: /_static/img/Edv_DConnector.png
   :align: center


.. note::

   7 wires are connected to the D-connector (including shield) since some of them are shared on the 5-pin connector end. To avoid confusion, match the connection with **wire colours** as demonstrated	in the figures.

The connection between 5-pin connector and D-connector (two ends of the cable between sensors and amplifiers) is listed as following:

- Yellow -- PSEN+
- Red -- P+
- Green -- S+
- Black -- P-
- Blue -- PSEN-
- White -- S-

Since these sensors were collected from different places, there are two types of connection (wire soldering order on the connector) as shown below. **Please check the connection type first if the sensor does not work.**

.. image:: /_static/img/Edv_ConnectionType.png
   :align: center


This table lists the relation between the colour of sensor labels and the connection type. **Please refer to this table if you want to remake any cables.**

.. table:: Endevco Sensor Wire Connection Type
   :widths: auto

   ============  ====== ===== ====== ====== ===== ===== ===== ====
   Label Colour  Yellow Green Orange Purple Black White Brown Blue
   ============  ====== ===== ====== ====== ===== ===== ===== ====
       Type        1      1     1       1     2     2     2    1
   ============  ====== ===== ====== ====== ===== ===== ===== ====

.. _Force Balance:

Force Balance (ATI)
-------------------

The type of the force balance is ATI Gamma FT17393, SI-130-10. (*Add a link to repo for calibration files*) The drawing of ATI Gamma is shown in the figure below. On the mounting side, there are four 6.6 thru holes for M6 SHCS, which will be fixed on a wooden plate underneath the Ahmed body. On the tool side, four M6 tap holes are used to fix the body via tooling parts, and forces from the body will be applied to this side. 

.. image:: /_static/img/FB_Drawing.png

For installation details, the mounting side on the wooden plate and the plate for the tool side are shown respectively in the picture below.

.. image:: /_static/img/FB_Plate.png
   :align: center
   :scale: 60%

.. note::

   When installing, make sure the ``X`` direction on the force balance is aligned with the flow direction.

.. warning::

   ATI Gamma FT17393 has load limitations as ±130 N for Fx and Fy, ±400N for Fz, ±10Nm for Tx and Ty. Be careful of the load when installing it! (e.g. when screwing the bolts, you can easily apply a large torque on it) It is better to measure the loads while installing to make sure they are under the limits.

.. _Linear Screw:

Linear Screw
------------

The linear screw in the Ahmed body is used to adjust static position of the flaps. In the present experiment, linear screws are only used to tare the static flap angles. For details of taring flaps and Labview code for implementation, please refer to :ref:`Taring <Taring>`.

**Add a picture of a linear screw used in this experiment.**

.. note::

   Sometimes the linear screws can be stuck due to motor ageing and lack of lubricant. Try to help it move manually or open the model to lubricate it, or change new DC motors.


