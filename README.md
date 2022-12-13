# SPI
********************************************************************************
Technical Requirements:

1. Satisfy the SPI Protocol:

        According to SPI Protocol, the transmission happens between one Master
    and several Slaves. The data channels include MISO (Master Input Slave Output),
    MOSI (Master Output Slave Input), CS (Chip selection), SCLK (System Clock).
    Based on different Clock Polarity (CPOL) and Clock Phase (CPHA), we control the
    off state of SCLK and which edge we are using to capture data.
    
2. User Interface Design:

        We also need user channels to control the SPI transmission, which include
    start, data, to indicate the start and data of packet we are sending, data 
    received and done signals for both sending and receiving.

3. IO Ports:

    System Ports:
        input               sys_clk;
        input               sys_rst_n;

    User Ports:
        input               SPI_start;
        input   [7:0]       data_send;
        output  [7:0]       data_receive;
        output              send_done;
        output              receive_done;

    Physical Ports:
        input               MISO;
        output              SCLK;
        output              MOSI;
        output              CS_n;               // Chip Select Negative: 0 for ON

4. Behavior Analysis:

    During Sending:
        (1) SPI_start will be 1 for one cycle; data_send will be available to
            store in registers
        (2) CS_n will be 0 during transmission; SCLK will start; Based on different
            CPOL and CPHA, data will be sent
        (3) SPI_end will be 1 for one cycle; CS_n will be 1; transmission stop; done
            signals will be 1
