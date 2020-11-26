# Relatório de Sistemas Embarcados - SSC0740
## Trabalho 01 - Extração de Contornos

#### Alunos:
Nome | Número USP
----|:----:
Breno Cunha Queiroz | 11218991
Lucas de Medeiros França Romero | 11219154
Lucas Yuji Matubara | 10734432

<br>

### A Operação
A extração de contornos é uma operação de processamento de imagens que se baseia em identificar pontos em uma imagem onde há mudança brusca de brilho em relação a outro ponto ou área, os quais são chamados de contornos. É a busca por descontinuidades no brilho da imagem.

Nesse trabalho, utilizamos o método de extração que faz a erosão dos pixels de uma imagem A a partir de um kernel B, e depois subtrai a erosão da imagem. 

> Imagem do livro com o esquema de erosão

Em nossas abordagens, entretanto, a operação de subtração da imagem pela erosão é condensada junto com o próprio cálculo da erosão, sendo o valor resultante o valor final da operação para o pixel (d), em vez do valor da erosão para aquele pixel \(c\). 

<br>

### O Código
Foram produzidos com sucesso dois códigos, de acordo com as especificações do trabalho, sendo uma implementação que maximiza o throughput e outra que minimiza o uso de recursos de hardware.

Os códigos recebem como entrada uma imagem em escala de cinza, no formato hexadecimal, de tamanho 320x240, sendo esse tamanho editável no código, e realizam a mesma operação de cálculo sobre os pixels da imagem:
```c
erosion =       ((pixels[0]<127) | (pixels[1]<127) | (pixels[2]<127) 
        	| (pixels[3]<127)                   | (pixels[5]<127)
         	| (pixels[6]<127) | (pixels[7]<127) | (pixels[8]<127))
        	&& (pixels[4]>127);
            
out[y*width+x] <= pixels[4]*erosion;
```
Em que o pixel `pixels[4]` é o pixel que está sendo alterado, com base em seu arredor, por meio da atribuição a `out[y*width+x]`. Ao final de todas as operações, é escrito um arquivo de saída, cujo nome é especificado no *testbench* da abordagem, que corresponde aos contornos da imagem de entrada, no formato hexadecimal.

O programa [`bmpHex.cpp`](https://github.com/Brenocq/FPGA-BorderDetection/blob/main/src/bmpHex.cpp "Programa de conversão no repositório do projeto") pode ser usado para converder uma imagem *.bmp* em RGB para *.hex* em escala de cinza, para gerar a entrada para a operação. E a saída gerada pode ser transformada de *.hex* para *.png* pelo mesmo programa, para visualização do arquivo de saída.

#### Abordagem que maximiza o throughput
Nessa abordagem, cada pixel é calculado em paralelo, em um único clock, a partir de *for-loops* que se expandem e são executados simultaneamente:

```c
//maxThroughput.sv
for (y = 1; y < height-1; y = y+1) begin
    for (x = 1; x < width-1; x = x+1) begin
        reg[7:0] pixels [0:8];
        reg[7:0] erosion;
        
        pixels[0] = in[(y-1)*width+x-1];
        pixels[1] = in[(y-1)*width+x];
        pixels[2] = in[(y-1)*width+x+1];
        pixels[3] = in[(y)*width+x-1];
        pixels[4] = in[(y)*width+x];
        pixels[5] = in[(y)*width+x+1];
        pixels[6] = in[(y+1)*width+x-1];
        pixels[7] = in[(y+1)*width+x];
        pixels[8] = in[(y+1)*width+x+1];

        erosion =       ((pixels[0]<127) | (pixels[1]<127) | (pixels[2]<127) 
        	        | (pixels[3]<127)                   | (pixels[5]<127)
         	        | (pixels[6]<127) | (pixels[7]<127) | (pixels[8]<127))
        	       && (pixels[4]>127);

        out[y*width+x] <= pixels[4]*erosion;
    end
end
```

##### Esquematização do hardware
> Esquema gerado pelo Yosis

#### Abordagem que minimiza o uso de hardware
Nessa abordagem, visando diminuir drasticamente o uso do hardware com memória que não está sendo utilizada, as operações são realizadas de acordo com a linha de pixels que está sendo calculada, sendo 3 o número mínimo de linhas na memória para que os cálculos sejam realizados, haja vista que são necessários os valores dos pixels nas linhas imediatamente superior e inferior ao pixel que está sendo visitado para a operação, diminuindo, assim, a memória utilizada de 320x240, para 3x240.

Nesse sentido, o programa inicia lendo duas linhas, e então realiza a operação a cada nova linha que lê, a cada clock, e ao final, escreve no arquivo de saída:

```c 
//minHardwareTest.sv
for (y=0; y<2; y=y+1) begin
    for (x=0; x<`WIDTH; x=x+1) begin
        in1[x] <= in2[x];
        in2[x] <= in3[x];
        read = $fscanf(fileIn,"%h",in3[x]);
    end
end

clk=1;
for (y=0; y<`HEIGHT; y=y+1) begin
    @(posedge clk) begin
        y = y+1;

        for (x=0; x<`WIDTH; x=x+1) begin
            in1[x] <= in2[x];
            in2[x] <= in3[x];
            read = $fscanf(fileIn,"%h",in3[x]);
        end

        for (x=0; x<`WIDTH; x=x+1) begin
            $fwrite(fileOut, "%h ", out[x]);
        end
    end
end
```

Ao final do processamento de cada linha, a linha mais antiga é descartada, e uma nova linha é lida, e funciona no seguinte esquema de memória:
Linha | Status
----|----
1 | Linha mais antiga
2 | Linha sendo processada
3 | Linha mais recente

E após um clock:
Linha | Status
----|----
2 | Linha mais antiga
3 | Linha sendo processada
4 | Linha mais recente

Onde todos os pixels da linha são processados em paralelo:
```c 
//minHardware.sv
always @(posedge clk) begin
    for(x = 1; x < (`WIDTH-1); x = x+1) begin
        reg[7:0] pixels [0:8];
        reg[7:0] erosion;

        pixels[0] = in1[x-1];
        pixels[1] = in1[x];
        pixels[2] = in1[x+1];
        pixels[3] = in2[x-1];
        pixels[4] = in2[x];
        pixels[5] = in2[x+1];
        pixels[6] = in3[x-1];
        pixels[7] = in3[x];
        pixels[8] = in3[x+1];

        erosion =       ((pixels[0]<127) | (pixels[1]<127) | (pixels[2]<127) 
        	        | (pixels[3]<127)                   | (pixels[5]<127)
         	        | (pixels[6]<127) | (pixels[7]<127) | (pixels[8]<127))
        	       && (pixels[4]>127);

        out[y*width+x] <= pixels[4]*erosion;
    end
end
```

##### Esquematização do hardware
> Esquema gerado pelo Yosis

<br>

### Resultados
#### Abordagem que minimiza o uso de hardware
> Imagem 1 fica aqui

> Imagem 2 fica aqui

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque nisl eros, 
pulvinar facilisis justo mollis, auctor consequat urna. Morbi a bibendum metus. 
Donec scelerisque sollicitudin enim eu venenatis. Duis tincidunt laoreet ex, 
in pretium orci vestibulum eget. Class aptent taciti sociosqu ad litora torquent
per conubia nostra, per inceptos himenaeos.

#### Abordagem que maximiza o throughput
> Imagem 1 fica aqui

> Imagem 2 fica aqui

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque nisl eros, 
pulvinar facilisis justo mollis, auctor consequat urna. Morbi a bibendum metus. 
Donec scelerisque sollicitudin enim eu venenatis. Duis tincidunt laoreet ex, 
in pretium orci vestibulum eget. Class aptent taciti sociosqu ad litora torquent
per conubia nostra, per inceptos himenaeos.

<br>

### Simulação de Hardware
> Síntese pelo Mentor Precision

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque nisl eros, 
pulvinar facilisis justo mollis, auctor consequat urna. Morbi a bibendum metus. 
Donec scelerisque sollicitudin enim eu venenatis. Duis tincidunt laoreet ex, 
in pretium orci vestibulum eget. Class aptent taciti sociosqu ad litora torquent
per conubia nostra, per inceptos himenaeos.
