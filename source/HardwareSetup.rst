.. _Hardware Setup:

Hardware Setup
==============

This section covers all the hardware setup for the experiment, including sensor cabling, Ahmed body assembly, and wind tunnel installation, etc. 

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

The circuit box is sealed in a metal box to avoid electromagnetic interference. The output connection from circuit box to PXI (via BNC-2110 connector) corresponds to following:

- VDD -- Black wire -- 5V
- Vss -- Green wire -- Digital Ground
- CLK -- Blue wire  -- PFI13 (CTR1 OUT)
- CSn -- BNC cable  -- PFI12 (CTR0 OUT)
- DO  -- PicoBlade wires -- P0.0 - P0.3 (refer to Labview code)

.. _Flaps:

Flaps & Power Box
-----------------

.. _ESP:

Pressure Taps (ESP)
-------------------

.. _Endevco:

Pressure Transducers (Endevco)
------------------------------

.. _Force Balance:

Force Balance (ATI)
-------------------

The type of the force balance is ATI Gamma FT17393, SI-130-10. (*Add a link to repo for calibration files*) The drawing of ATI Gamma is shown in figure below. On mounting side, there are four 6.6 thru holes for M6 SHCS, which will be fixed on a wooden plate underneath the Ahmed body. On tool side, four M6 tap holes are used to fix the body via tooling parts, and forces from the body will be applied to this side. 

.. image:: /_static/img/FB_Drawing.png

For installation details, the mounting side on the wooden plate and the plate for tool side are shown respectively in the picture below.

.. image:: /_static/img/FB_Plate.png

.. note::

   When installing, make sure the ``X`` direction on the force balance is aligned with flow direction.

.. warning::
   ATI Gamma FT17393 has load limitations as ±130 N for Fx and Fy, ±400N for Fz, ±10Nm for Tx and Ty. Be careful of the load when installing it! (e.g. when screwing the bolts, you can easily apply a large torque on it) It is better to measure the loads while installing to make sure they are under the limits.

.. _Linear Screw:

Linear Screw
------------
 

