[![Abrir en VS Code Web](https://img.shields.io/badge/Abrir%20en-VS%20Code%20Web-blue?logo=visualstudiocode&logoColor=white)](https://vscode.dev/github/jpulidof/Proyecto-EDI-Smarcount-G5-E4)



# Proyecto Final Electrónica Digital I SmartCount

# Integrantes
- Orozco. R. Ana
- Ospina. P. Stefannie
- Pulido. F. José

# Informe

Indice:

1. [Diseño implementado](#diseño-implementado)
2. [Simulaciones](#simulaciones)
3. [Implementación](#implementación)
4. [Conclusiones](#conclusiones)
5. [Referencias](#referencias)

## Diseño implementado
El diseño implementado en este proyecto se basa en una banda transportadora sobre la cual se desplazan cubos que deben ser contados automáticamente. Para ello, se utiliza un sensor de ultrasonido que detecta la presencia de cada cubo al pasar por un punto específico de la banda. La señal generada por el sensor es procesada por una FPGA, que cumple la función de unidad de control central del sistema. La FPGA interpreta las señales, incrementa un contador y actualiza en tiempo real la cantidad de cubos detectados en una pantalla LCD. Esta integración permite una supervisión clara y precisa del proceso, asegurando la confiabilidad del sistema incluso a velocidades de transporte variables.

La elección de una FPGA como núcleo del sistema responde a la necesidad de contar con una plataforma flexible, reconfigurable y capaz de ejecutar múltiples tareas en paralelo, como la lectura del sensor, el procesamiento del conteo y el control de la visualización. El diseño modular implementado permite una fácil adaptación a otras aplicaciones similares en el ámbito industrial, donde se requiere automatizar procesos de conteo o clasificación. Además, la sincronización precisa entre los componentes garantiza un funcionamiento coordinado y eficiente. 

### Descripción
A continuación se presenta la descripción de cada módulo que compone el proyecto para cada uno de los elementos que lo componen:

#### Pantalla LCD
  
El módulo LCD1602_controller implementa un controlador para una pantalla LCD tipo 1602, permitiendo mostrar tanto texto estático como datos numéricos dinámicos. El controlador se basa en una máquina de estados finitos (FSM) que gestiona de forma secuencial la i0nicialización de la pantalla, la escritura de mensajes predefinidos en ambas líneas y la actualización periódica del contenido dinámico, como la cantidad de objetos contados. El texto estático se almacena en una memoria cargada desde archivo, mientras que los valores dinámicos se reciben como entrada (in) y se descomponen en centenas, decenas y unidades para su visualización en formato ASCII.

Para cumplir con los tiempos requeridos por la pantalla, el módulo emplea un divisor de frecuencia que genera pulsos cada 16 ms. A cada transición del pulso, se avanza en la FSM para enviar comandos o datos según el estado actual. La lógica de escritura dinámica permite mostrar números de hasta tres dígitos, usando una pequeña máquina de estados dentro del estado DYNAMIC_TEXT. Este diseño modular y parametrizable no solo cumple con los requerimientos de interfaz, sino que también permite adaptarse fácilmente a otros sistemas embebidos basados en FPGA que requieran salida visual clara y actualizable.

![Diagrama de estados](images2/estados_LCD.png)

* Descripción de cada estado:
- IDLE:	Espera la señal ready_i. Se resetean los contadores.
- CONFIG_CMD1: Se envían comandos de inicialización desde config_mem.
- WR_STATIC_TEXT_1L: 	Se escribe la primera línea del mensaje estático desde static_data_mem.
- CONFIG_CMD2:	Se envía el comando para pasar a la segunda línea (START_2LINE).
- WR_STATIC_TEXT_2L:	Se escribe la segunda línea del mensaje estático.
- DYNAMIC_TEXT:	Se actualizan los tres dígitos del valor de entrada in (centena, decena, unidad), mostrando el número en ASCII. Avanza con flag_case.


#### Puente H

El módulo controlador_motor gestiona la activación, dirección y velocidad de un motor de corriente continua mediante señales de control y modulación por ancho de pulso (PWM), utilizando una arquitectura basada en lógica secuencial. El sistema opera en tres estados (IDLE, CLOCK_WISE y COUNTER_CLOCK_WISE), definidos por la señal de entrada sel, y emplea una máquina de estados finitos (FSM) sencilla para controlar la dirección del motor a través de las señales AIN1 y AIN2. Además, incorpora una función de pausa temporal activada mediante el pulsador boton_pausa, la cual detiene el motor durante aproximadamente 2 segundos utilizando un contador sincronizado al reloj de 50 MHz, desactivando la señal PWM durante ese intervalo como medida de seguridad o control manual. La señal PWMA, que regula la velocidad del motor, se genera con una frecuencia cercana a 24 kHz mediante un divisor de reloj, y su ciclo de trabajo (duty cycle) se ajusta dinámicamente mediante la entrada pwm_duty. Esta implementación permite un control eficiente y flexible del motor en aplicaciones de automatización basadas en FPGA.

![Diagrama de puente H](https://github.com/jpulidof/Proyecto-EDI-Smarcount-G5-E4/blob/main/images/estados%20puenteH.jpg?raw=true)

* Descripción de cada estado:
- IDLE: El motor está detenido sin movimiento. Es el estado inicial tras un reinicio (reset).
- CLOCK_WISE: El motor gira en sentido horario. La corriente fluye del terminal A al B del motor.
- COUNTER_CLOCK_WISE: El motor gira en sentido antihorario.
- PROTECTION (pausa activa): El motor se detiene temporalmente por seguridad o por pulsación del botón, sin importar el valor de sel.

#### Sensor infrarrojo
El módulo top_ultrasonic funciona como la unidad principal de integración del sistema. Se encarga de contar los eventos generados por el sensor de infrarrojo y mostrar dicho conteo en la pantalla LCD, además de gestionar la integración del motor dentro del sistema. Para cumplir con estas funciones, instancia varios módulos previamente descritos: antirrebote, que filtra la señal proveniente del sensor infrarrojo; contador, que registra el número de eventos detectados; LCD1602_controller, encargado de mostrar el valor del contador en la pantalla LCD; y controlador_motor, que determina el sentido de giro, la activación y la velocidad del motor. En conjunto, este módulo coordina la interacción entre las distintas partes del sistema, asegurando un funcionamiento sincronizado y confiable.

#### Otros módulos

Adicionalmente, para completar el sistema fue necesario incluir otros módelos además de los encargados de cada sensor, los cuales se presentan a continuación:

- Circuito antirebote: Un circuito antirrebote es un sistema diseñado para eliminar las lecturas erróneas causadas por los rebotes eléctricos que se producen cuando una señal digital cambia de estado, como ocurre comúnmente con botones o entradas mecánicas. En el contexto de un sensor de infrarrojo, el antirrebote se aplica típicamente a la señal de entrada del pin out, que indica la detección de un objeto. Si esta señal presenta fluctuaciones rápidas o inestables debido a interferencias o ruido, el sistema podría interpretar múltiples detecciones falsas o medir distancias incorrectas. El circuito antirrebote sincroniza esta señal con el reloj del sistema y verifica que el cambio de estado se mantenga constante durante un tiempo mínimo antes de considerarlo válido. De esta manera, se asegura que solo se registren transiciones reales y estables, mejorando la precisión y confiabilidad de la medición del sensor infrarrojo.
  
- Contador: El módulo contador implementa un contador ascendente de 10 bits, lo que le permite contar hasta un valor máximo de 1023. Su valor se incrementa cuando se detecta un flanco de subida en la señal de entrada cuenta. A diferencia de los contadores tradicionales, no utiliza el reloj principal de la FPGA como señal de sincronización, ya que su propósito específico es contar los objetos detectados por el sensor ultrasónico, reaccionando únicamente a los eventos generados por dicho sensor.

## Simulaciones 

<!-- (Incluir las de Digital si hicieron uso de esta herramienta, pero también deben incluir simulaciones realizadas usando un simulador HDL como por ejemplo Icarus Verilog + GTKwave) -->

![Diagrama de estados](images2/antirrebote.jpeg)
![Diagrama de estados](images2/contador.jpeg)
![Diagrama de estados](images2/motor.jpeg)
![Diagrama de estados](images2/LCD.jpeg)



## Implementación

El proyecto se enfocó en el desarrollo de un sistema automatizado, basado en FPGA, para el conteo de cubos que se desplazaban sobre una banda transportadora. Para detectar cada elemento, se utilizó un sensor ultrasónico cuya señal fue procesada por la FPGA. Esta actuó como unidad de control, incrementando un contador y mostrando en una pantalla LCD el número total de cubos detectados en tiempo real. El diseño permitió mantener un funcionamiento confiable incluso cuando la velocidad de transporte variaba, y su estructura modular ofrece la posibilidad de adaptarlo fácilmente a otras aplicaciones industriales que requieran tareas similares de conteo o clasificación.

Se optó por emplear una FPGA debido a su capacidad de ejecutar varias operaciones en paralelo, lo que facilitó la integración de la lectura del sensor, el procesamiento del conteo y el control de la visualización. Esta característica, sumada a su flexibilidad y posibilidad de reconfiguración, hizo que el sistema resultara eficiente y escalable.

Como complemento, se implementó un circuito antirrebote destinado a mejorar la estabilidad de la señal proveniente del pin \texttt{echo} del sensor HC-SR04. Gracias a este filtrado, se evitaron lecturas falsas ocasionadas por fluctuaciones o interferencias, lo que contribuyó a aumentar la precisión y la confiabilidad de las mediciones obtenidas.


 
## Anexos

![Diagrama de LCD](images/lcd_page-0001.jpg)
![Diagrama de LCD](images/puente%20h_page-0001.jpg)


## Conclusiones
  - El proyecto permitió aplicar el concepto de máquinas de estados finitos en un caso real de automatización, reforzando nuestra comprensión de este modelo computacional y su implementación en hardware programable.
    
 - La implementación del sensor TCS34725 con el protocolo I2C en la FPGA presentó desafíos inesperados, principalmente por la inestabilidad en la comunicación y desconocimiento del manejo del mismo. Aunque se resolvió posteriormente con un sensor infrarojo, evidenció que protocolos "sencillos" como I2C requieren diseño cuidadoso . Este problema retrasó el desarrollo, pero dejó lecciones valiosas para futuras integraciones de sensores.

  - Este proyecto demostró que se pueden crear sistemas de automatización accesibles para pequeñas empresas usando FPGAs, tal como planeamos al principio. Aunque tuvimos problemas para conectar algunos componentes, el sistema aunque no funciona en su totalidad, cumple con lo propuesto. Lo más valioso fue aprender resolviendo desafíos reales, que es justo lo que buscábamos con este trabajo.

## Referencias
