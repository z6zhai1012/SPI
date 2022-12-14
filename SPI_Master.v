// *****************************************************************************
// Author: Zhen Zhai
// Date: 12/13/2022
// 
// Module Name: SPI_Master
//      1. A simple implementation of SPI Master
//      2. All logic is done assuing CPOL = 0, CPHA = 0
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
    reg     [1:0]           clk_counter;        // using sys_clk to count spi_sclk
    reg     [3:0]           bits_counter;       // counter for bit position
    reg     [7:0]           data_reg;           // regs for sending and receiving


// ******************************//
// Registers' Behaviors
// ******************************//
    // clk_counter behavior
    always @ (posedge sys_clk or negedge sys_reset_n) begin
        if (!sys_reset_n)
            clk_counter     <=  2'b00;
        else if (!spi_cs_n) begin
            if (clk_counter == 2'b11)
                clk_counter     <=  2'b00;
            else
                clk_counter     <=  clk_counter + 1'b1;
        end
        else
            clk_counter     <=  2'b00;
    end

    // data_reg behavior
    always @ (posedge sys_clk or negedge sys_reset_n) begin
        if (!sys_reset_n)
            data_reg    <=  0;
        else begin
            if (spi_start)
                data_reg    <=  data_send;
            // reuse the same reg for accepting data assuming CPOL, CPHA = 0
            else if ((clk_counter == 2'b10) && !spi_cs_n)begin
                data_reg[bits_counter]  <=  spi_miso;
            end
            else
                data_reg    <=  data_reg;
        end
    end

    // bits_counter behavior
    always @ (posedge sys_clk or negedge sys_reset_n) begin
        if (!sys_reset_n)
            bits_counter    <=  4'b000;
        // When CS is 0 and there is an uprising edge
        else if ((clk_counter == 2'b10) && !spi_cs_n)
            bits_counter    <=  bits_counter + 4'b001;
        else
            bits_counter    <=  bits_counter;
    end
// ******************************//
// Registers' Behaviors END
// ******************************//

// ******************************//
// Output Ports' Behaviors
// ******************************//
    // generate spi_sclk
    always @ (posedge sys_clk or negedge sys_reset_n) begin
        if (!sys_reset_n)
            spi_sclk    <=  CPOL;
        else if (!spi_cs_n) begin
            if (clk_counter == 2'b00)
                spi_sclk    <=  CPOL;
            else if (clk_counter == 2'b10)
                spi_sclk    <=  ~spi_sclk;
            else
                spi_sclk    <=  spi_sclk;
        end
        else
            spi_sclk <= CPOL;
    end

    // generate spi_cs_n
    always @ (posedge sys_clk or negedge sys_reset_n) begin
        if (!sys_reset_n)
            spi_cs_n    <=  1'b1;
        else if (spi_start)
            spi_cs_n    <=  1'b0;
        else if (bits_counter == 4'b1000)
            spi_cs_n    <=  1'b1;
    end

    // spi_mosi behavior
    always @ (posedge sys_clk or negedge sys_reset_n) begin
        if (!sys_reset_n)
            spi_mosi    <=  1'b0;
        // send LSB first
        else if ((clk_counter == 2'b00) && !spi_cs_n) begin
            spi_mosi    <=  data_reg[bits_counter];
        end
    end

    // data_receive, send_done, receive done behaviors
    always @ (posedge sys_clk or negedge sys_reset_n) begin
        if (!sys_reset_n) begin
            data_receive    <=  8'b0;
            send_done       <=  1'b0;
            rec_done        <=  1'b0;
        end
        else if ((bits_counter == 4'b1000)&&(clk_counter == 2'b11)) begin
            data_receive    <=  data_reg;
            send_done       <=  1'b1;
            rec_done        <=  1'b1;
        end
        else begin
            send_done       <=  1'b0;
            rec_done        <=  1'b0;
        end
    end

// ******************************//
// Output Ports' Behaviors END
// ******************************//

endmodule