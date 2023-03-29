Wind Tunnel Experiment for Ahmed Body Drag Reduction using Active Flow Control by Reinforcement Learning
====================================================================

This is a documentation example about experimental setup and progress note of the Ahmed body flow control experiment in the wind tunnel at Imperial College London.

- **PXI-PC Communication and Data Acquisition**: A UDP-based communication is used for transfering data between a PXI DAQ system and a host PC
- **Labview-Python Interaction Design**: Labview codes were developed for data acquisition and Python codes were used to implement reinforcement learning
- **RL Algorithm**: The RL Algorithm is provided by StableBaselines 3 and StableBaselines 3 contrib


.. toctree::
  :maxdepth: 0
  :caption: Instructions

  Instructions/Wind Tunnel Setup
  Instructions/Sensors & Wirings

.. toctree::
  :maxdepth: 0
  :caption: General Setup
  
  General Setup/Angle Measurement
  General Setup/Force Measurement
  General Setup/Pressure Measurement
  General Setup/Power Measurement


.. toctree::
   :maxdepth: 1
   :caption: Progress Notes

   Progress Notes/March 2023
   Progress Notes/May 2023

