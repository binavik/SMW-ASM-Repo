if !sa1 == 0
	!additional_sprite_table = $7F828B	;12 bytes
else
	!additional_sprite_table = $406000	;22 bytes
endif
!flag = $18BB
!additional_ram = $1487

!turn_timer = $04


;format: -------T
;-: unused
;T: Platform type: 0 = solid, 1 = semi-solid
!platform_settings = $00
