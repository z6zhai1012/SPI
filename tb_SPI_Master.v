// *****************************************************************************
// Author: Zhen Zhai
// Date: 12/13/2022
// 
// Module Name: tb_SPI_Master
//      1. A simple testbench for module SPI_Master
//
// *****************************************************************************
`timescale 1ns/1ns

module tb_SPI_Master();

    reg                 sys_clk;
    reg                 sys_reset_n;
    reg                 spi_start;
    reg     [7:0]       data_send;
    wire    [7:0]       data_receive;
    wire                send_done;
    wire                rec_done;
    reg                 spi_miso;
    wire                spi_sclk;
    wire                spi_mosi;
    wire                spi_cs_n;

    SPI_Master SPI_Master_inst(
        .sys_clk(sys_clk),
        .sys_reset_n(sys_reset_n),
        .spi_start(spi_start),
        .data_send(data_send),
        .data_receive(data_receive),
        .send_done(send_done),
        .rec_done(rec_done),
        .spi_miso(spi_miso),
        .spi_sclk(spi_sclk),
        .spi_cs_n(spi_cs_n),
        .spi_mosi(spi_mosi)
    );

    always #10 sys_clk = ~sys_clk;

    initial begin
        sys_clk     <=  0;
        sys_reset_n <=  1'b0;
        spi_start   <=  1'b0;
        data_send   <=  8'd0;
        spi_miso    <=  1'bz;

        #80
        sys_reset_n <=  1'b1;
        #40
        spi_start   <=  1'b1;
        data_send   <=  8'b10101010;
        #20
        spi_start   <=  1'b0;
        @(posedge send_done)
        #80
        $finish;
    end

endmodule