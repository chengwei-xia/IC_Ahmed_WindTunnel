.. _Software Setup:

Software Setup
==============

This document includes the implementation of data acquisition and Reinforcement Learning in the wind tunnel real-time experiment. The software framework is built in a PXI-PC system via network connection.

Languages
---------

* Python: UDP connection and Reinforcement Learning.
* Labview: UDP connection, data acquisition, and data visualisation & saving.

.. note::

   Users need to be familiar with Python and Labview.

.. _installation:

Installation
------------

To run this experiment with Reinforcement Learning, Python 3.9 and the following Python packages are required:

* numpy
* pip
* drl-platform == 0.1.5
* gym == 0.21.0
* pytorch >= 1.11 (with cuda if running on GPU)
* tensorboard == 2.11.2
* sb3-contrib == 1.7.0 (this will install Stable Baselines3 together)


`Anaconda <https://conda.io/projects/conda/en/latest/user-guide/index.html>`_ is recommended to use for creating a Python environment. A GUI version of anaconda can help to create an environment, or using the command line:

.. code-block:: console

   $ conda create -n ENV_NAME python=3.9
   $ condo activate ENV_NAME

The installation commands of the required packages is shown below through *anaconda*:

.. code-block:: console

   (ENV_NAME) $ pip install drl-platform
   (ENV_NAME) $ pip install gym==0.21.0
   (ENV_NAME) $ pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
   (ENV_NAME) $ pip install tensorboard==2.11.2
   (ENV_NAME) $ pip install sb3-contrib

.. note::

   The commands of installation may change over time (especially pytorch). Please search for the latest commands corresponding to the version if the commands in this document fail.
   There may be a conflict of package version due to drl-platform and gym. Please ignore this or try other versions to solve the issue.

`Labview <https://www.ni.com/en-gb/shop/labview.html>`_ 2021 is used to handle data acquisition	and communication together with NI devices such as PXI and PCIe card. Details of hardware setup please see :ref:`Hardware Setup <Hardware Setup>`.

A Real-time Labview module needs to be installed both on PXI and host PC. First, download and install Labview and VI Package Manager on host PC. The Real-time module can be installed/modified from the VI Package Manager as the `official support <https://knowledge.ni.com/KnowledgeArticleDetails?id=kA03q000000x1r4CAA&l=en-GB>`_.

After installing the Real-time Labview on host PC, for the next step, the PXI needs to be booted in RT mode and connected to the host PC. Please see `Real-time PXI`_ for details.

.. _Real-time PXI:

Real-time PXI
-------------

If your PXI is still in Windows/Linux system, it needs to be formatted and booted in RT mode to run real-time experiments. For PXIe-8135, which is used in the current experiments, it can be booted in RT mode via BIOS panel (recommended) and hardware switch (a switch on the back of PXI hardware, see manual if not clear).

Please see the `official instruction <https://knowledge.ni.com/KnowledgeArticleDetails?id=kA03q000000YHpZCAW&l=en-GB>`_ to boot your PXI via a USB drive or follow the procedures below to boot your PXI in RT mode directly (both methods use the BIOS panel):

-  Connect PXI and PC via network (RT module is installed on PXI via PC).
-  Press ``Delete`` when starting the PXI to enter the BIOS panel, and under ``LabVIEW RT``, change ``Boot Configuration`` to LabVIEW RT.
-  Open NI MAX in host PC and right click the PXI target to format it. Choose ``Reliance File System`` during formatting.
-  Right click the PXI target again in the NI MAX and select add/install software, select LabVIEW Real-Time 21.0.0 and Network Streams 21.0. Leave other add-ons by default. See `Install Software <https://knowledge.ni.com/KnowledgeArticleDetails?id=kA03q000000YILGCA4&l=en-GB>`_ for further support.

Then, the RT PXI can be connected to the PC in Labview:

-  Create a project in the Labview on PC.
-  Right click on the project target and select ``New Targets and Devices``. Select target type as ``RT PXI`` to find your PXI target. Add the target.
-  Right click the PXI target in project explorer. Click ``Connect`` to connect your PXI and PC.

.. note::

   Sometimes the PXI and PC cannot be connected successfully. Restart both PC and PXI, and shut down the firewall on the PC side.

.. note::

   If VIs are saved and deployed under the PXI target, they will run on the PXI instead of the PC. More details of how to run the Labview codes please refer to :ref:`Experiment Manual <Experiment Manual>`. See a `YouTube tutorial <https://www.youtube.com/watch?v=I43pZm0SeCQ>`_ to get familiar with running Labview in RT target.

.. PXI-Host Connection:

PXI-Host Connection
-------------------

The PXI is connected to the host PC using a network with UDP protocol. To set up the connection, use consistent IP addresses for both sides, such as **192.168.10.xxx**. Specify also the **port number** for sending and receiving data on both PXI (Labview) and host PC (Python).


The UDP time chart is shown in the figure below (to update).

.. image:: /_static/img/TimeChart.png
   :align: center
   :scale: 60%

.. note::

   Be careful when setting the timeout for UDP read function in Labview. When this timeout is too large, during the resetting of RL algorithm, the frequency of the RT loop will drop to the timeout frequency and the RT feature will be broken. When this timeout is too small, Labview reads data from UDP before Python sends new data, so Labview will read data from the previous step (shifted when the code begins).




   
