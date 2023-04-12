.. IC_Ahmed_WindTunnel documentation master file, created by
   sphinx-quickstart on Fri Mar 31 17:52:37 2023.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Wind Tunnel Experiment Docs (Imperial College London) - Ahmed Body Drag Reduction via Reinforcement Learning
============================================================================================================

This is the laboratory document of the wind tunnel experiment on Reinforcement Learning flow control for drag reduction of an Ahmed body. This experiment is developed on the basis of the research of Brackston et al. 2016 (see ref) and the same Ahmed body model is used. 

This document records details of implementing data acquisition and Reinforcement Learning algorithm (see section :ref:`Software Setup <Software Setup>`), cabling of sensors and installation of Ahmed body (see section :ref:`Hardware Setup <Hardware Setup>`), and the procedure of running the experiment properly (see section :ref:`Experiment Manual <Experiment Manual>`).

.. note::

   More information about Reinforcement Learning code implementation in `github <https://github.com/RigasLab/RL_2DCylinder_FlowControl_SB3>`_.

For a general introduction, the diagram below shows the framework of this wind tunnel experiment. The experiment consists of three major components: a host PC with a PCIe-6320 card, a real-time PXIe-8135 (PXI for short), and a wind tunnel environment with Ahmed body installed.

.. image:: /_static/img/Exp_Framework.png

Contents
--------

.. toctree::

   SoftwareSetup
   HardwareSetup
   ExpManual
