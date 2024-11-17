; **********************************************************************
; *** 						   SADDA PROYECT		  			     ***
; ***  Sistema de Ayuda a la Decisión para el Diagnóstico de Anemia  ***
; **********************************************************************



; ***template para almacenar los datos de cada paciente***
(deftemplate Paciente
	(multifield Nombre)
	(field Edad (type INTEGER))
	(field Sexo)
)

; ***template para almacenar las posibles afecciones***
(deftemplate Afeccion
	(multifield Diagnosticado)
)


; ***Regla para dar la bienvenida al usuario***
(defrule init
=>
	(printout t "<----------------------------------------------------------------------------->" crlf crlf)
	(printout t "SSSS    A   DDDD  DDDD    A " crlf)
	(printout t "S      A A  D   D D   D  A A" crlf)
	(printout t "SSSS  AAAAA D   D D   D AAAAA" crlf)
	(printout t "    S A   A D   D D   D A   A" crlf)
	(printout t "SSSS  A   A DDDD  DDDD  A   A" crlf crlf)
	(printout t "       ****    ****    " crlf)
	(printout t "      ******  ******" crlf)
	(printout t "       ************" crlf)
	(printout t "         ********    " crlf)
	(printout t "          ******     " crlf)
	(printout t "            **       " crlf crlf)
	(printout t "<----------------------------------------------------------------------------->" crlf)
	(printout t "                       Bienvenid@ al sistema SADDA" crlf)
	(printout t "<----------------------------------------------------------------------------->" crlf)
	
	; para iniciar la interacción con el usuario	
	(assert(init))

)


; ***Regla para pedir los datos del paciente*** 
(defrule PedirDatosPaciente
	(init)
=>
	(printout t "Introduzca su nombre:" crlf)
	(bind ?nombre (readline))
	(printout t "Introduzca su edad:" crlf)
	(bind ?edad (read))
	(printout t "Introduzca su sexo (M/F):" crlf)
	(bind ?sexo (read))

	; Convertir el valor de edad en un entero
	(bind ?edad-integer (integer ?edad))

	; Se añade el nuevo paciente a la base de hechos
	(assert (Paciente
			(Nombre ?nombre)
			(Edad ?edad-integer)
			(Sexo ?sexo)
		)
	)
	; El primer paso sería pedir los niveles de hemoglobina al paciente
	(assert(Pedir hemoglobina))
)


; **********************************************************************
; 					       Reglas para pedir datos

; ***Pedir hemoglobina***
(defrule PedirHemoglobina
	(Pedir hemoglobina)
=>
	(printout t "Hemoglobina (alta/normal/baja):" crlf)
	(bind ?hemoglobina (read))

	; Se añade el hecho sobre la hemoglobina
	(assert
		(Hemoglobina ?hemoglobina)
	)
)

; ***Pedir VCM***
(defrule PedirVCM
	(Pedir VCM)
=>
	(printout t "VCM (volumen corpuscular medio) (alto/normal/bajo):" crlf)
	(bind ?VCM (read))

	; Se añade el hecho sobre el VCM
	(assert
		(VCM ?VCM)
	)
)


; ***Pedir datos anemia microcitica***
(defrule PedirDatosAnemiaMicrocitica
	(Pedir datos anemia microcitica)
=>
	; Valor del Fe (hierro)
	(printout t "Fe (hierro) (alto/normal/bajo):" crlf)
	(bind ?fe (read))

	; Valor de la Ferritina
	(printout t "Ferritina (alta/normal/baja):" crlf)
	(bind ?ferritina (read))
	
	; Valor de la CTFH
	(printout t "CTFH (capacidad total de fijacion de hierro) (alta/normal/baja):" crlf)
	(bind ?ctfh (read))

	; Se añade el hecho sobre el hierro
	(assert(Fe ?fe))

	; Se añade el hecho sobre la ferritina
	(assert(Ferritina ?ferritina))

	; Se añade el hecho sobre la CTFH
	(assert(CTFH ?ctfh))

	; Si el hierro es normal o alto hay que tener en cuenta los Reticulocitos 
	(if (or (eq ?fe normal)(eq ?fe alto))
		then
			; Valor de los Reticulocitos
			(printout t "Reticulocitos (altos/normales/bajos):" crlf)
			(bind ?retis (read))
			
			; Se añade el hecho sobre los Reticulocitos
			(assert(Reticulocitos ?retis))
	)

	; Para saber que se está calculando el diagnóstico (en el caso de no eliminarse, es porque no se ha encontrado ningún diagnostico)
	(assert(calcular diagnostico))
)



; ***Pedir datos anemia normocitica***
(defrule PedirDatosAnemiaNormocitica
	(Pedir datos anemia normocitica)
=>
	; Valor de los Reticulocitos
	(printout t "Reticulocitos (altos/normales/bajos):" crlf)
	(bind ?retis (read))

	; Se añade el hecho sobre los Reticulocitos
	(assert(Reticulocitos ?retis))

	; Dependiendo del valor de los Reticulocitos se preguntan unas cosas u otras
	(if (eq ?retis bajos)
		then
			; Valor del Fe (hierro)
			(printout t "Fe (hierro) (alto/normal/bajo):" crlf)
			(bind ?fe (read))

			; Valor de la CTFH
			(printout t "CTFH (capacidad total de fijacion de hierro) (alta/normal/baja):" crlf)
			(bind ?ctfh (read))

			; Valor de la Ferritina
			(printout t "Ferritina (alta/normal/baja):" crlf)
			(bind ?ferritina (read))

			; Se añade el hecho sobre el hierro
			(assert(Fe ?fe))

			; Se añade el hecho sobre la ferritina
			(assert(Ferritina ?ferritina))

			; Se añade el hecho sobre la CTFH
			(assert(CTFH ?ctfh))

			; Para saber que se está calculando el diagnóstico (en el caso de no eliminarse, es porque no se ha encontrado ningún diagnostico)
			(assert(calcular diagnostico))
	)
	(if (eq ?retis altos)
		then
		; Con o sin sangrado agudo
		(printout t "¿El paciente sufre sangrado agudo? (si/no):" crlf)
		(bind ?sangradoagudo (read))
		
		(if (eq ?sangradoagudo si)
		then
			; Se añade un hecho para indicar que sí hay sangrado agudo
			(assert(Con sangrado agudo))

			; Para saber que se está calculando el diagnóstico (en el caso de no eliminarse, es porque no se ha encontrado ningún diagnostico)
			(assert(calcular diagnostico))
		)

		(if (eq ?sangradoagudo no)
		then
			; Se añade un hecho para indicar que no hay sangrado agudo
			(assert(Sin sangrado agudo))

			; Valor del LDH (lactatodeshidrogenasa sérica)
			(printout t "LDH (lactatodeshidrogenasa serica) (alta/normal/baja):" crlf)
			(bind ?ldh (read))

			; Valor de la bilirrubina indirecta
			(printout t "Bi ind. (bilirrubina indirecta) (alta/normal/baja):" crlf)
			(bind ?biind (read))

			; Valor de la Haptoglobina
			(printout t "Haptoglobina (alta/normal/baja):" crlf)
			(bind ?haptoglobina (read))

			; Se añade el hecho sobre la LDH
			(assert(LDH ?ldh))

			; Se añade el hecho sobre la bilirrubina indirecta
			(assert(Bi ind. ?biind))

			; Se añade el hecho sobre la Haptoglobina
			(assert(Haptoglobina ?haptoglobina))
		)
	)
)



; ***Pedir datos anemia macrocitica***
(defrule PedirDatosAnemiaMacrocitica
	(Pedir datos anemia macrocitica)
=>
	; Valor de los Reticulocitos
	(printout t "Reticulocitos (altos/normales/bajos):" crlf)
	(bind ?retis (read))

	; Se añade el hecho sobre los Reticulocitos
	(assert(Reticulocitos ?retis))

	; Dependiendo del valor de los Reticulocitos se preguntan unas cosas u otras
	(if (eq ?retis altos)
		then
		; Con o sin sangrado agudo
		(printout t "¿El paciente sufre sangrado agudo? (si/no):" crlf)
		(bind ?sangradoagudo (read))
		
		(if (eq ?sangradoagudo si)
		then
			; Se añade un hecho para indicar que sí hay sangrado agudo
			(assert(Con sangrado agudo))

			; Para saber que se está calculando el diagnóstico (en el caso de no eliminarse, es porque no se ha encontrado ningún diagnostico)
			(assert(calcular diagnostico))
		)

		(if (eq ?sangradoagudo no)
		then
			; Se añade un hecho para indicar que no hay sangrado agudo
			(assert(Sin sangrado agudo))
			
		)
	)
	(if (eq ?retis bajos)
		then
		; Valor de la Vitamina B12
		(printout t "Vit. B12 (vitamina B12) (alta/normal/baja):" crlf)
		(bind ?vitb12 (read))

		; Valor del ácido fólico
		(printout t "A. folico (acido folico) (alto/normal/bajo):" crlf)
		(bind ?folico (read))

		; Se añade un hecho sobre la vitamina B12
		(assert(Vit.B12 ?vitb12))
		; Se añade un hecho sobre el ácido fólico
		(assert(A. folico ?folico))

		; Para saber que se está calculando el diagnóstico (en el caso de no eliminarse, es porque no se ha encontrado ningún diagnostico)
		(assert(calcular diagnostico))
	)
)




; ***Pedir datos para determinar tipo de anemia hemolítica***
(defrule PedirDatosAnemiaHemolitica
	(Anemia hemolitica)
=>
	; Realizar test de Coombs
	(printout t "Diagnosticado anemia hemolitica. Para determinar el tipo, realizar test de Coombs (PAD)." crlf)
	(printout t "Resultado del test (pudiendo ser positivo o negativo) (+/-):" crlf)
	(bind ?testcoombs (read))
		
	(if (eq ?testcoombs +)
	then
		(assert(Test de Coombs positivo))
		(assert(Fin diagnostico))
	)
	(if (eq ?testcoombs -)
	then
		(assert(Test de Coombs negativo))
		(assert(Fin diagnostico))
	)
	
	; Para saber que se está calculando el diagnóstico (en el caso de no eliminarse, es porque no se ha encontrado ningún diagnostico)
	(assert(calcular diagnostico))
)


; **********************************************************************
; 							¿Tiene anemia?

; ***Sí tiene anemia***
(defrule R1
	(Hemoglobina baja)
=>
	(assert(Si anemia))
	(printout t "El paciente si tiene anemia. Se procedera a realizar el diagnostico." crlf)

	; Al tener anemia, se pide el VCM con el objetivo de determinar el tipo de anemia
	(assert(Pedir VCM))
)


; ***No tiene anemia***
(defrule R2
	(Hemoglobina normal|alta)
=>
	(assert(No anemia))
	(printout t "No anemia, estudiar otras causas." crlf)
	(assert(calcular diagnostico))
)




; **********************************************************************
; 							Tipo de anemia

; ***Anemia microcítica***
(defrule R3
	(Si anemia)
	(VCM bajo)
=>
	(assert(Anemia microcitica))
	(printout t "Sospecha de anemia microcitica." crlf)
	(assert(Pedir datos anemia microcitica))
)


; ***Anemia normocítica***
(defrule R4
	(Si anemia)
	(VCM normal)
=>
	(assert(Anemia normocitica))
	(printout t "Sospecha de anemia normocitica." crlf)
	(assert(Pedir datos anemia normocitica))
)


; ***Anemia macrocítica***
(defrule R5
	(Si anemia)
	(VCM alto)
=>
	(assert(Anemia macrocitica))
	(printout t "Sospecha de anemia macrocitica." crlf)
	(assert(Pedir datos anemia macrocitica))
)






; **********************************************************************
; 				    Diagnóstico de anemias microcíticas

; ***Regla 6: Sospecha de anemia sideroblástica***
(defrule R6
	(Anemia microcitica)
	(Fe normal|alto)
	(Ferritina alta)
	(CTFH normal|alta)
	(Reticulocitos bajos)
=>
	(assert(Afeccion(Diagnosticado "Sospecha de anemia sideroblastica")))
	(assert(Fin diagnostico))
)


; ***Regla 7: Sospechar talasemia***
(defrule R7
	(Anemia microcitica)
	(Fe normal|alto)
	(Ferritina alta)
	(CTFH normal|alta)
	(Reticulocitos normales|altos)
=>
	(assert(Afeccion(Diagnosticado "Sospechar talasemia")))
	(assert(Fin diagnostico))
)


; ***Regla 8: Anemia ferropénica***
(defrule R8
	(Anemia microcitica)
	(Fe bajo)
	(Ferritina baja)
	(CTFH alta)
=>
	(assert(Afeccion(Diagnosticado "Anemia ferropenica")))
	(assert(Fin diagnostico))
)


; ***Regla 9: Anemia de enfermedades crónicas***
(defrule R9
	(Anemia microcitica)
	(Fe bajo)
	(Ferritina baja)
	(CTFH normal|baja)
=>
	(assert(Afeccion(Diagnosticado "Anemia de enfermedades cronicas")))
	(assert(Fin diagnostico))
)


; ***Regla 10: Valorar coexistencia anemia ferropénica y anemia de enfermedades crónicas***
(defrule R10
	(Anemia microcitica)
	(Fe bajo)
	(Ferritina normal|baja)
	(CTFH baja)
=>
	(assert(Afeccion(Diagnosticado "Valorar coexistencia anemia ferropenica y anemia de enfermedades cronicas")))
	(assert(Fin diagnostico))
)



; **********************************************************************
; 				   Diagnóstico de anemias normocíticas

; ***Regla 11: Anemia de enfermedades crónicas***
(defrule R11
	(Anemia normocitica)
	(Reticulocitos bajos)
	(Fe bajo)
	(CTFH baja|normal)
	(Ferritina alta)
=>
	(assert(Afeccion(Diagnosticado "Anemia de enfermedades cronicas")))
	(assert(Fin diagnostico))
)


; ***Regla 12: Anemia hemolítica (AH)***
(defrule R12
	(Anemia normocitica)
	(Reticulocitos altos)
	(LDH alta)
	(Bi ind. alta) 
	(Haptoglobina baja)
=>
	(assert(Anemia hemolitica))
)


; ***Regla 13: Anemia posthemorrágica aguda***
(defrule R13
	(Anemia normocitica)
	(Reticulocitos altos)
	(Con sangrado agudo)
=>
	(assert(Afeccion(Diagnosticado "Anemia posthemorragica aguda")))
	(assert(Fin diagnostico))
)



; **********************************************************************
; 				    Diagnóstico de anemias macrocíticas

; ***Regla 14: Anemia perniciosa, malabsorción o vegetarianismo***
(defrule R14
	(Anemia macrocitica)
	(Reticulocitos bajos)
	(Vit.B12 baja)

=>
	(assert(Afeccion(Diagnosticado "Anemia perniciosa, malabsorcion o vegetarianismo")))
	(assert(Fin diagnostico))
)


; ***Regla 15: Anemia megaloblástica folicopénica***
(defrule R15
	(Anemia macrocitica)
	(Reticulocitos bajos)
	(A. folico bajo)
=>
	(assert(Afeccion(Diagnosticado "Anemia megaloblastica folicopenica")))
	(assert(Fin diagnostico))
)


; ***Regla 16: SMD-síndromes mielodisplásicos***
(defrule R16
	(Anemia macrocitica)
	(Reticulocitos bajos)
	(Vit.B12 normal)
	(A. folico normal)

=>
	(assert(Afeccion(Diagnosticado "SMD-sindromes mielodisplasicos")))
	(assert(Fin diagnostico))
)



; ***Regla 17: Anemia hemolítica (AH)***
(defrule R17
	(Anemia macrocitica)
	(Reticulocitos altos)
	(Sin sangrado agudo)
=>
	(assert(Anemia hemolitica))
)


; ***Regla 18: Anemia posthemorrágica aguda***
(defrule R18
	(Anemia macrocitica)
	(Reticulocitos altos)
	(Con sangrado agudo)
=>
	(assert(Afeccion(Diagnosticado "Anemia posthemorragica aguda")))
	(assert(Fin diagnostico))
)







; **********************************************************************
; 		 Diagnóstico para determinar el tipo de anemia hemolítica

; ***Regla 19: Anemia hemolítica autoinmune***
(defrule R19
	(Anemia hemolitica)
	(Test de Coombs positivo)
=>
	(assert(Afeccion(Diagnosticado "Anemia hemolitica autoinmune")))
	(assert(Fin diagnostico))
)


; ***Regla 20: Anemia hemolítica no autoinmune***
(defrule R20
	(Anemia hemolitica)
	(Test de Coombs negativo)
=>
	(assert(Afeccion(Diagnosticado "Anemia hemolitica no autoinmune")))
	(assert(Fin diagnostico))
)





; **********************************************************************
; 							Fin diagnostico

; ***Regla para mostrar el informe final del diagnostico NO SE HA ENCONTRADO UN RESULTADO***
(defrule SinDiagnostico
	(declare (salience -1))
	(calcular diagnostico)
	(Paciente
		(Nombre ?nombre)
		(Edad ?edad)
		(Sexo ?sexo)
	)
	(not(Fin diagnostico))
=>
	(printout t crlf crlf ">====================================================================<" crlf crlf)
	(printout t "> DIAGNOSTICO --> " crlf crlf)
	(printout t "> Nombre: " ?nombre crlf)
	(printout t "> Edad: " ?edad crlf)
	(printout t "> Sexo: " ?sexo crlf crlf)
	(printout t "> Resultado: Tras el analisis clinico, lamentablemente no hemos logrado determinar un diagnostico." crlf)
	(printout t "Por lo tanto, recomendamos programar una cita para llevar a cabo pruebas mucho mas exhaustivas" crlf)
	(printout t "y precisas que nos permitan llegar a un diagnostico certero." crlf crlf)
	(printout t ">====================================================================<" crlf)
	(printout t ">====================================================================<" crlf crlf)
	(printout t "Gracias por usar el sistema SADDA." crlf) 
)


; ***Regla para mostrar el informe final del diagnostico***
(defrule FinDiagnostico
	(Fin diagnostico)
	(Paciente
		(Nombre ?nombre)
		(Edad ?edad)
		(Sexo ?sexo)
	)
	(Afeccion(Diagnosticado ?diagnostico))
=>
	(printout t crlf crlf ">====================================================================<" crlf crlf)
	(printout t "> DIAGNOSTICO --> " crlf crlf)
	(printout t "> Nombre: " ?nombre crlf)
	(printout t "> Edad: " ?edad crlf)
	(printout t "> Sexo: " ?sexo crlf crlf)
	(printout t "> Resultado: " ?diagnostico  crlf crlf)
	(printout t ">====================================================================<" crlf)
	(printout t ">====================================================================<" crlf crlf)
	(printout t "Gracias por usar el sistema SADDA." crlf) 
)



