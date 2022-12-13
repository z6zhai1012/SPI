// *****************************************************************************
// Author: Zhen Zhai
// Date: 12/13/2022
// 
// Module Name: SPI_Master
//      1. A simple implementation of SPI Master
//
// Input Ports:
//      1. sys_clk                  : System Clock Provided
//      2. sys_reset_n              : Reset Negative
//      3. spi_start                : Start Transmission
//      4. data_send [7:0]          : Data to be sent
//      5. spi_miso                 : Data coming from slave
//
// Output Port:
//      1. data_rec [7:0]           : Data received from slave
//      2. send_done                : Sending is done
//      3. rec_done                 : Receiving is done
//      4. spi_sclk                 : Clock to be shared to slave
//      5. spi_cs_n                 : Chip Select (0 to turn on slave)
//      6. spi_mosi                 : Data to send to slave
//
// *****************************************************************************

module SPI_Master
#(
    parameter CPOL = 0,
    parameter CPHA = 0
)
(
    // System Ports
    input                   sys_clk,
    input                   sys_reset_n,

    // User Ports
    input                   spi_start,
    input       [7:0]       data_send,
    output  reg [7:0]       data_receive,
    output  reg             send_done,
    output  reg             rec_done,

    // SPI Physical Ports
    input                   spi_miso,
    output  reg             spi_sclk,
    output  reg             spi_cs_n,
    output  reg             spi_mosi
);

    reg     [1:0]           clk_counter;        // account for CPOL, CPHA
    reg     [2:0]           bits_counter_rec;   // counter for receiving
    reg     [2:0]           bits_counter_send;  // counter for sending

    // generate spi_sclk
    always @ (posedge sys_clk or negedge sys_reset_n) begin
        if (!sys_reset_n)
            spi_sclk <= CPOL;
        else if (!spi_cs_n) begin
            spi_sclk <= ~spi_sclk;
        end
        else
            spi_sclk <= CPOL;
    end

    // clk_counter behavior
    always @ (posedge sys_clk or negedge sys_reset_n) begin
        if (!sys_reset_n)
            clk_counter <= 2'b00;
        else if (!spi_cs_n) begin
            if (clk_counter == 2'b11)
                clk_counter <= 2'b00;
            else
                clk_counter <= clk_counter + 1'b1;
        end
        else
            clk_counter <= 2'b00;
    end

    // bits_counter_rec

    // generate spi_cs_n
    always @ (posedge sys_clk or negedge sys_reset_n) begin
        if (!sys_reset_n)
            spi_cs_n <= 1'b1;
        else if (spi_start)
            spi_cs_n <= 1'b0;
        else if (bit_cnt_send == 3'b111)
            spi_cs_n <= 1'b1;
    end

    // 

endmodule