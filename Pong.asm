; =====================================================================================================================
; =====================================================================================================================
; 
;           _____                   _______                   _____                    _____                      
;          /\    \                 /::\    \                 /\    \                  /\    \                     
;         /::\    \               /::::\    \               /::\____\                /::\    \                    
;        /::::\    \             /::::::\    \             /::::|   |               /::::\    \                   
;       /::::::\    \           /::::::::\    \           /:::::|   |              /::::::\    \                  
;      /:::/\:::\    \         /:::/~~\:::\    \         /::::::|   |             /:::/\:::\    \                 
;     /:::/__\:::\    \       /:::/    \:::\    \       /:::/|::|   |            /:::/  \:::\    \                
;    /::::\   \:::\    \     /:::/    / \:::\    \     /:::/ |::|   |           /:::/    \:::\    \               
;   /::::::\   \:::\    \   /:::/____/   \:::\____\   /:::/  |::|   | _____    /:::/    / \:::\    \              
;  /:::/\:::\   \:::\____\ |:::|    |     |:::|    | /:::/   |::|   |/\    \  /:::/    /   \:::\ ___\             
; /:::/  \:::\   \:::|    ||:::|____|     |:::|    |/:: /    |::|   /::\____\/:::/____/  ___\:::|    |            
; \::/    \:::\  /:::|____| \:::\    \   /:::/    / \::/    /|::|  /:::/    /\:::\    \ /\  /:::|____|            
;  \/_____/\:::\/:::/    /   \:::\    \ /:::/    /   \/____/ |::| /:::/    /  \:::\    /::\ \::/    /             
;           \::::::/    /     \:::\    /:::/    /            |::|/:::/    /    \:::\   \:::\ \/____/              
;            \::::/    /       \:::\__/:::/    /             |::::::/    /      \:::\   \:::\____\                
;             \::/____/         \::::::::/    /              |:::::/    /        \:::\  /:::/    /                
;              ~~                \::::::/    /               |::::/    /          \:::\/:::/    /                 
;                                 \::::/    /                /:::/    /            \::::::/    /                  
;                                  \::/____/                /:::/    /              \::::/    /                   
;                                   ~~                      \::/    /                \::/____/                    
;                                                            \/____/                                              
;                                                                                                                 
; =====================================================================================================================
; =====================================================================================================================



; =====================================================================================================================
STACK SEGMENT PARA STACK
	DB 64 DUP (' ')
STACK ENDS
; =====================================================================================================================
; =====================================================================================================================


; =====================================================================================================================
DATA SEGMENT PARA 'DATA'

	; Window definition
	WINDOW_WIDTH DW 140h                   ; -> Window width to define the boundary (320 pixels)
	WINDOW_HEIGHT DW 0C8h                  ; -> Window height to define the boundary (200 pixels)
	WINDOW_BOUNDS DW 6                     ; -> Variable used to check colisions early

	TIME_OLD DB 0                          ; -> Variable used to storage the old time value
 
	; Ball data
	ORIGINAL_X DW 0A0h                     ; -> Initial x position of the ball
	ORIGINAL_Y DW 64h                      ; -> Initial y position of the ball
	BALL_X DW 0A0h                         ; -> Sets the x position (column)
	BALL_Y DW 64h                          ; -> Sets the y position (row)
	BALL_SIZE DW 04h                       ; -> Size of the ball (it is a square)
	
	BALL_VELOCITY_X DW 05h                 ; -> Velocity of the ball in X
	BALL_VELOCITY_Y DW 02h                 ; -> Velocity of the ball in Y
	
	; Paddles data
	PADDLE_LEFT_X DW 0Ah
	PADDLE_LEFT_Y DW 55h
	PADDLE_RIGHT_X DW 130h
	PADDLE_RIGHT_Y DW 55h
	PADDLE_WIDHT DW 03h
	PADDLE_HEIGHT DW 1Fh
	
	PADDLE_VELOCITY DW 08h
	
	PLAYER_ONE_POINTS DB 0
	PLAYER_TWO_POINTS DB 0
	
	PLAYER_ONE_POINTS_TEXT DB '0','$'      ; -> Text with player one points
	PLAYER_TWO_POINTS_TEXT DB '0','$'      ; -> Text with player two points
	
	AI_CONTROLLED DB 0                     ; -> Used to move the right paddle
	
	; Used to see if the game is active
	GAME_ACTIVE DB 1                       ; -> 1 = Active | 0 = Game Over
	
	TEXT_GAME_OVER_TITLE DB 'GAME OVER','$'; -> Game Over menu title
	TEXT_GAME_OVER_WINNER DB 'Player 0 won!','$'; -> Text with the winner text
	WINNER_INDEX DB 0                      ; -> Used to determine which player has won
	TEXT_GAME_OVER_PLAY_AGAIN DB 'Press R to restart the game...','$' ; -> Play again message
	TEXT_GAME_OVER_MAIN_MENU DB 'Press E to return to Main Menu','$' ; -> Exit to main menu message
	
	; Main menu test
	TEXT_MAIN_MENU_TITLE DB 'MAIN MENU','$' ; -> Main menu title
	TEXT_MAIN_MENU_SINGLE_PLAYER DB 'Single Player -> Press S','$' ; -> Single player option text
	TEXT_MAIN_MENU_MULTI_PLAYER DB 'Multi Player -> Press M','$' ; -> Multi player option text
	TEXT_MAIN_MENU_EXIT DB 'Exit Game - Press E','$' ; -> To exit the game
	
	CURRENT_SCENE DB 0                      ; -> Index used to set which scene it will be displayed (0 is menu, 1 is game)
	
	EXITING_GAME DB 0                       ; -> Used to exit the game

DATA ENDS
; =====================================================================================================================
; =====================================================================================================================


; =====================================================================================================================
CODE SEGMENT 'CODE'

	; Main Procedure
	; =================================================================================================================
	MAIN PROC FAR
	
		ASSUME CS:CODE, DS:DATA, SS:STACK  ; Assume these segments as the respective registers
		PUSH DS                            ; Push the DS segment to the stack
		SUB AX, AX                         ; Clean the AX register
		PUSH AX                            ; Push the AX register to the stack 
		MOV AX, DATA                       ; Saves on the AX register the contents of the DATA segment
		MOV DS, AX                         ; Saves on the DS segment the contents of the AX register
		POP AX                             ; Releases the top item from the stack to the AX register
		POP AX                             ; Releases the top item from the stack to the AX register
		
		CALL UPDATE_SCREEN
		CALL DRAW_PADDLES
		
		CHECK_TIME:
			
			; Checks if the user wants to wxit the game
			CMP EXITING_GAME, 01h
			JE EXIT_PROCESS
			
			; Checks the scene
			CMP CURRENT_SCENE, 00h
			JE SHOW_MAIN_MENU
			
			
			; See if the game is over
			CMP GAME_ACTIVE, 00h
			JE SHOW_GAME_OVER
			
			; Get the system time
			MOV AH, 2Ch
			INT 21h
			
			CMP DL, TIME_OLD               ; -> Compares the 1/100 second and the old time
			JE CHECK_TIME                  ; -> Rechecks the time if it is equal
			
			; Runs if the time step has passed on
			MOV TIME_OLD, DL               ; -> Updates the old time variable  
			
			CALL MOVE_BALL                 ; -> Updates the ball position
			
			CALL UPDATE_SCREEN             ; -> Erases the screen
			
			CALL DRAW_BALL                 ; -> Redraws the ball
			
			CALL MOVE_PADDLES              ; -> Moves the paddles
			CALL DRAW_PADDLES              ; -> Redraws the paddles
			
			CALL DRAW_UI                   ; -> Draws all the user interface texts
			
			JMP CHECK_TIME                 ; -> Check time again
			
			SHOW_GAME_OVER:
				CALL DRAW_GAME_OVER_MENU
				JMP CHECK_TIME
			
			SHOW_MAIN_MENU:
				CALL DRAW_MAIN_MENU
				JMP CHECK_TIME
				
			EXIT_PROCESS:
				CALL EXIT_GAME_PROC
		
		RET
	MAIN ENDP
	; =================================================================================================================
	
	
	; Draws game over menu
	; =================================================================================================================
	DRAW_GAME_OVER_MENU PROC NEAR
		CALL UPDATE_SCREEN
		
		; Shows Game Over menu
		MOV AH, 02h                       ; -> Set Cursor Position
		MOV BH, 00h                       ; -> Set page number
		MOV DH, 04h                       ; -> Set row to be displayed
		MOV DL, 06h                       ; -> Set column to be displayed
		INT 10h
		
		MOV AH, 09h                       ; -> Writes the string
		LEA DX, TEXT_GAME_OVER_TITLE
		INT 21h                           ; -> Executes the configuration
		
		;Shows the winner
		MOV AH, 02h                       ; -> Set Cursor Position
		MOV BH, 00h                       ; -> Set page number
		MOV DH, 06h                       ; -> Set row to be displayed
		MOV DL, 06h                       ; -> Set column to be displayed
		INT 10h
		
		CALL UPDATE_WINNER_TEXT           ; -> Updates the text to be displayed informing the winner
		
		MOV AH, 09h                       ; -> Writes the string
		LEA DX, TEXT_GAME_OVER_WINNER
		INT 21h                           ; -> Executes the configuration
		
		;Shows the play again message
		MOV AH, 02h                       ; -> Set Cursor Position
		MOV BH, 00h                       ; -> Set page number
		MOV DH, 08h                       ; -> Set row to be displayed
		MOV DL, 06h                       ; -> Set column to be displayed
		INT 10h

		MOV AH, 09h                       ; -> Writes the string
		LEA DX, TEXT_GAME_OVER_PLAY_AGAIN
		INT 21h                           ; -> Executes the configuration
		
		;Shows the return to mais menu message
		MOV AH, 02h                       ; -> Set Cursor Position
		MOV BH, 00h                       ; -> Set page number
		MOV DH, 10h                       ; -> Set row to be displayed
		MOV DL, 06h                       ; -> Set column to be displayed
		INT 10h

		MOV AH, 09h                       ; -> Writes the string
		LEA DX, TEXT_GAME_OVER_MAIN_MENU
		INT 21h                           ; -> Executes the configuration
		
		;Verifies if the restart key was pressed
		MOV AH, 00h
		INT 16h
		
		CMP AL, 'R'
		JE RESTART_GAME
		
		CMP AL, 'r'
		JE RESTART_GAME
		
		;Verifies if the main menu key was pressed
		CMP AL, 'E'
		JE EXIT_TO_MAIN_MENU
		
		CMP AL, 'e'
		JE EXIT_TO_MAIN_MENU
		
		RET
		
		RESTART_GAME:
			MOV GAME_ACTIVE, 01h
			RET
		
		EXIT_TO_MAIN_MENU:
			MOV GAME_ACTIVE, 00h
			MOV CURRENT_SCENE, 00h
		
		
	DRAW_GAME_OVER_MENU ENDP
	; =================================================================================================================
	
	
	; Draws the main menu window
	; =================================================================================================================
	DRAW_MAIN_MENU PROC NEAR
		
		CALL UPDATE_SCREEN
		
		; Shows MAIN MENU title
		MOV AH, 02h                       ; -> Set Cursor Position
		MOV BH, 00h                       ; -> Set page number
		MOV DH, 04h                       ; -> Set row to be displayed
		MOV DL, 06h                       ; -> Set column to be displayed
		INT 10h
		
		MOV AH, 09h                       ; -> Writes the string
		LEA DX, TEXT_MAIN_MENU_TITLE
		INT 21h                           ; -> Executes the configuration
		
		; Shows MAIN MENU single player option
		MOV AH, 02h                       ; -> Set Cursor Position
		MOV BH, 00h                       ; -> Set page number
		MOV DH, 06h                       ; -> Set row to be displayed
		MOV DL, 06h                       ; -> Set column to be displayed
		INT 10h
		
		MOV AH, 09h                       ; -> Writes the string
		LEA DX, TEXT_MAIN_MENU_SINGLE_PLAYER
		INT 21h                           ; -> Executes the configuration
		
		; Shows MAIN MENU multi player option
		MOV AH, 02h                       ; -> Set Cursor Position
		MOV BH, 00h                       ; -> Set page number
		MOV DH, 08h                       ; -> Set row to be displayed
		MOV DL, 06h                       ; -> Set column to be displayed
		INT 10h
		
		MOV AH, 09h                       ; -> Writes the string
		LEA DX, TEXT_MAIN_MENU_MULTI_PLAYER
		INT 21h                           ; -> Executes the configuration
		
		; Shows MAIN MENU exit game option
		MOV AH, 02h                       ; -> Set Cursor Position
		MOV BH, 00h                       ; -> Set page number
		MOV DH, 10h                       ; -> Set row to be displayed
		MOV DL, 06h                       ; -> Set column to be displayed
		INT 10h
		
		MOV AH, 09h                       ; -> Writes the string
		LEA DX, TEXT_MAIN_MENU_EXIT
		INT 21h                           ; -> Executes the configuration
		
		MAIN_MENU_WAIT_FOR_KEY:
			;Waits for the key to be pressed
			MOV AH, 00h
			INT 16h
			
			CMP AL, 'S'
			JE START_SINGLE_PLAYER
			CMP AL, 's'
			JE START_SINGLE_PLAYER
			
			CMP AL, 'M'
			JE START_MULTI_PLAYER
			CMP AL, 'm'
			JE START_MULTI_PLAYER
			
			CMP AL, 'E'
			JE EXIT_GAME
			CMP AL, 'e'
			JE EXIT_GAME
			
			JMP MAIN_MENU_WAIT_FOR_KEY
			
		START_SINGLE_PLAYER:
			MOV CURRENT_SCENE,01h
			MOV GAME_ACTIVE, 01h
			MOV AI_CONTROLLED, 01h
			RET
			
		START_MULTI_PLAYER:
			MOV CURRENT_SCENE,01h
			MOV GAME_ACTIVE, 01h
			MOV AI_CONTROLLED, 00h
			RET
			
		EXIT_GAME:
			MOV EXITING_GAME, 01h
			RET
	
	DRAW_MAIN_MENU ENDP
	; =================================================================================================================
	
	
	; Corrects the text with the winner to be displayed
	; =================================================================================================================
	UPDATE_WINNER_TEXT PROC NEAR
	
		MOV AL, WINNER_INDEX
		ADD AL, 30H
		MOV [TEXT_GAME_OVER_WINNER+7], AL
		
		RET
	UPDATE_WINNER_TEXT ENDP
	; =================================================================================================================
	
	
	; Erases the screen
	; =================================================================================================================
	UPDATE_SCREEN PROC NEAR
		
		; Sets video mode on
		MOV AH, 00h                       ; -> Configuration to video mode
		MOV AL, 0Dh                       ; -> Choose the video mode
		INT 10h                           ; -> Executes the configuration 
		
		; Sets the blackbackground
		MOV AH, 0Bh                       ; -> Configuration 
		MOV BH, 00h                       ; -> to the background color
		MOV BL, 00h                       ; -> Chooses the background color
		INT 10h                           ; -> Executes the configuration
		
		RET
	UPDATE_SCREEN ENDP
	; =================================================================================================================
	
	
	; Exits the game > RETURN TO TEXT MODE
	; =================================================================================================================
	EXIT_GAME_PROC PROC NEAR
		
		; Sets text mode on
		MOV AH, 00h                       ; -> Configuration to video mode
		MOV AL, 02h                       ; -> Choose the text mode
		INT 10h                           ; -> Executes the configuration 
		
		; Terminates the program
		MOV AH, 4Ch
		INT 21h
		
		RET
	EXIT_GAME_PROC ENDP
	; =================================================================================================================
	
	
	; Updates the ball position
	; =================================================================================================================
	MOVE_BALL PROC NEAR
		; Moves horizontally
		MOV AX, BALL_VELOCITY_X
		ADD BALL_X, AX
		
		; Compares if a collision has occured in x
		MOV AX, WINDOW_BOUNDS
		CMP BALL_X, AX                      ; -> Left side   
		JL INCREMENT_PLAYER_TWO_POINTS
		
		MOV AX, WINDOW_WIDTH
		SUB AX, BALL_SIZE
		SUB AX, WINDOW_BOUNDS
		CMP BALL_X, AX                      ; -> Right side
		JG INCREMENT_PLAYER_ONE_POINTS
		JMP MOVE_BALL_VERTICALLY
		
		; Increments players points
		INCREMENT_PLAYER_ONE_POINTS:
			INC PLAYER_ONE_POINTS
			NEG BALL_VELOCITY_X
			CALL RESET_BALL_POSITION
			
			CALL UPDATE_PLAYER_ONE_TEXT_POINTS	
			
			CMP PLAYER_ONE_POINTS, 05h
			JGE GAME_OVER
			
			RET
			
		INCREMENT_PLAYER_TWO_POINTS:
			INC PLAYER_TWO_POINTS
			NEG BALL_VELOCITY_X
			CALL RESET_BALL_POSITION
			
			CALL UPDATE_PLAYER_TWO_TEXT_POINTS
			
			CMP PLAYER_TWO_POINTS, 05h
			JGE GAME_OVER
			
			RET
			
		; Games over 
		GAME_OVER:
		
			;Checks which player has 5 points (is the winner)
			CMP PLAYER_ONE_POINTS, 05h
			JNL WINNER_PLAYER_ONE
			JMP WINNER_PLAYER_TWO
			
			; If player one is the winner
			WINNER_PLAYER_ONE:
				MOV WINNER_INDEX, 01h
				JMP CONTINUE_GAME_OVER
			
			; If player two is the winner
			WINNER_PLAYER_TWO:
				MOV WINNER_INDEX, 02h
				JMP CONTINUE_GAME_OVER
			
			CONTINUE_GAME_OVER:
				MOV PLAYER_ONE_POINTS, 00h
				MOV PLAYER_TWO_POINTS, 00h
				CALL UPDATE_PLAYER_ONE_TEXT_POINTS
				CALL UPDATE_PLAYER_TWO_TEXT_POINTS
				MOV GAME_ACTIVE, 00h
				RET
	
		; Moves vertically
			MOVE_BALL_VERTICALLY:
			
			MOV AX, BALL_VELOCITY_Y
			ADD BALL_Y, AX
			
			; Compares if a colLision has occured in y
			MOV AX, WINDOW_BOUNDS
			CMP BALL_Y, AX                  ; -> Top side  
			JL NEG_VELOCITY_Y 
			
			MOV AX, WINDOW_HEIGHT
			SUB AX, BALL_SIZE
			SUB AX, WINDOW_BOUNDS
			CMP BALL_Y, AX                  ; -> Bottom side
			JG NEG_VELOCITY_Y
			JMP COLLISION_WITH_PADDLES
			
			; Changes the way of movement in x
			NEG_VELOCITY_X:
				NEG BALL_VELOCITY_X             ; BALL_VELOCITY_X = - BALL_VELOCITY_X
				RET
				
			; Changes the way of movement in y
			NEG_VELOCITY_Y:
				NEG BALL_VELOCITY_Y             ; BALL_VELOCITY_Y = - BALL_VELOCITY_Y
				RET
			
			COLLISION_WITH_PADDLES:
				; Checks if the ball is colliding with the right paddle
				MOV AX, BALL_X
				ADD AX, BALL_SIZE
				ADD AX, 03h                     ; Corrects the collision
				CMP AX, PADDLE_RIGHT_X
				JNG CHECK_COLLISION_LEFT_PADDLE 
				
				MOV AX, PADDLE_RIGHT_X
				ADD AX, PADDLE_WIDHT
				CMP BALL_X, AX
				JNL CHECK_COLLISION_LEFT_PADDLE
				
				MOV AX, BALL_Y
				ADD AX, BALL_SIZE
				CMP AX, PADDLE_RIGHT_Y
				JNG CHECK_COLLISION_LEFT_PADDLE
				
				MOV AX, PADDLE_RIGHT_Y
				ADD AX, PADDLE_HEIGHT
				CMP BALL_Y, AX
				JNL CHECK_COLLISION_LEFT_PADDLE
				
				; Here happened the colLision with the right paddle
				NEG BALL_VELOCITY_X
				RET
				
				; Checks if the ball is colliding with the left paddle
				CHECK_COLLISION_LEFT_PADDLE:
					MOV AX, BALL_X
					ADD AX, BALL_SIZE
					CMP AX, PADDLE_LEFT_X
					JNG EXIT_COLLISION
					
					MOV AX, PADDLE_LEFT_X
					ADD AX, PADDLE_WIDHT
					SUB AX, 01h                 ; Corrects the collision
					CMP BALL_X, AX
					JNL EXIT_COLLISION
					
					MOV AX, BALL_Y
					ADD AX, BALL_SIZE
					CMP AX, PADDLE_LEFT_Y
					JNG EXIT_COLLISION
					
					MOV AX, PADDLE_LEFT_Y
					ADD AX, PADDLE_HEIGHT
					CMP BALL_Y, AX
					JNL EXIT_COLLISION
					
					; Here happened the colLision with the right paddle
					NEG BALL_VELOCITY_X
					RET
					
					EXIT_COLLISION:
						RET
				
				RET 
			
	MOVE_BALL ENDP
	; =================================================================================================================
	
	
	; Draws the ball
	; =================================================================================================================
	DRAW_BALL PROC NEAR
		
		MOV CX, BALL_X                    ; -> Sets the reference x position (column)
		MOV DX, BALL_Y                    ; -> Sets the reference y position (row)
		
		DRAW_BALL_SIDES:
			; Draws the pixel
			MOV AH, 0Ch                   ; -> Configuration to write the pixel
			MOV AL, 0Ah                   ; -> Chooses the pixel color (white)
			MOV BH, 00h                   ; -> Sets the page number
			INT 10h                       ; -> Executes the configuration
			
			; Evaluates the columns
			INC CX                        ; -> CX = CX + 1 (next column)
			MOV AX, CX                    ; -> Uses aux variable
			SUB AX, BALL_X                ; -> AX = AX - BALL_X
			CMP AX, BALL_SIZE             ; -> Compares AX and BALL_SIZE
			JNG DRAW_BALL_SIDES           ; -> If CMP result is "Not Greater" than go to DRAW_BALL_SIDES procedure else:
			
			; Evaluates the rows
			MOV CX, BALL_X                ; -> Returns to the first "column"
			INC DX                        ; -> DX = DX + 1 (next row)
			MOV AX, DX                    ; -> Uses aux variable
			SUB AX, BALL_Y                ; -> AX = AX - BALL_Y
			CMP AX, BALL_SIZE             ; -> Compares AX and BALL_SIZE
			JNG DRAW_BALL_SIDES	          ; -> If CMP result is "Not Greater" than go to DRAW_BALL_SIDES
			
		RET
	DRAW_BALL ENDP
	; =================================================================================================================

	
	; Moves the paddles
	; =================================================================================================================
	MOVE_PADDLES PROC NEAR
		; Checks if any key was pressed
		MOV AH, 01h
		INT 16h
		JZ CHECK_RIGHT_PADDLE_MOVEMENT    ; -> 
		
		MOV AH, 00h
		INT 16h
		
		; Checks if the pressed key values were to move the left paddle
		CMP AL, 77h ;(w)
		JE MOVE_LEFT_PADDLE_UP
		CMP AL, 57h ;(W)
		JE MOVE_LEFT_PADDLE_UP
		
		CMP AL, 73h ;(s)
		JE MOVE_LEFT_PADDLE_DOWN
		CMP AL, 53h ;(S)
		JE MOVE_LEFT_PADDLE_DOWN
		
		; If the pressed key was not S or W, checks if the key was for move the right paddle
		JMP CHECK_RIGHT_PADDLE_MOVEMENT
		
		; Moves the left paddle up
		MOVE_LEFT_PADDLE_UP:
			MOV AX, PADDLE_VELOCITY
			SUB PADDLE_LEFT_Y, AX
			
			MOV AX, WINDOW_BOUNDS
			CMP PADDLE_LEFT_Y, AX
			JL CORRECT_LEFT_PADDLE_UP_POSITION
			JMP CHECK_RIGHT_PADDLE_MOVEMENT
			
			CORRECT_LEFT_PADDLE_UP_POSITION:
				MOV AX, WINDOW_BOUNDS
				MOV PADDLE_LEFT_Y, AX
				JMP CHECK_RIGHT_PADDLE_MOVEMENT
		
		; Moves the left paddle down
		MOVE_LEFT_PADDLE_DOWN:
			MOV AX, PADDLE_VELOCITY
			ADD PADDLE_LEFT_Y, AX
			
			MOV AX, WINDOW_HEIGHT
			SUB AX, WINDOW_BOUNDS
			SUB AX, PADDLE_HEIGHT
			CMP PADDLE_LEFT_Y, AX
			JG CORRECT_LEFT_PADDLE_DOWN_POSITION
			JMP CHECK_RIGHT_PADDLE_MOVEMENT
			
			; Used to respect the window dimensions
			CORRECT_LEFT_PADDLE_DOWN_POSITION:
				MOV PADDLE_LEFT_Y, AX
				JMP CHECK_RIGHT_PADDLE_MOVEMENT
		
		; Checks if the pressed key was to move the right paddle
		CHECK_RIGHT_PADDLE_MOVEMENT:
		
			CMP AI_CONTROLLED, 01h
			JE CONTROL_BY_AI
			
			; If it is the multiplayer option
			CHECK_FOR_KEYS:
				CMP AL, 6Fh ;(o)
				JE MOVE_RIGHT_PADDLE_UP
				CMP AL, 4Fh ;(O)
				JE MOVE_RIGHT_PADDLE_UP
				
				CMP AL, 6Ch ;(l)
				JE MOVE_RIGHT_PADDLE_DOWN
				CMP AL, 4Ch ;(L)
				JE MOVE_RIGHT_PADDLE_DOWN
				
				; Exits the procedure if none of he movement keys were pressed
				JMP EXIT_PADDLE_MOVIMENT
				
			; If it is the singleplayer option
			CONTROL_BY_AI:
				; If the ball is above the paddle
				MOV AX, BALL_Y
				ADD AX, BALL_SIZE
				CMP AX, PADDLE_RIGHT_Y
				JL MOVE_RIGHT_PADDLE_UP
				
				;If ball is below the paddle
				MOV AX, PADDLE_RIGHT_Y
				ADD AX, PADDLE_HEIGHT
				CMP AX, BALL_Y
				JL MOVE_RIGHT_PADDLE_DOWN
				
				; If none of the conditions
				JMP EXIT_PADDLE_MOVIMENT
			
			; Moves the right paddle up
			MOVE_RIGHT_PADDLE_UP:
				MOV AX, PADDLE_VELOCITY
				SUB PADDLE_RIGHT_Y, AX
				
				MOV AX, WINDOW_BOUNDS
				CMP PADDLE_RIGHT_Y, AX
				JL CORRECT_RIGHT_PADDLE_UP_POSITION
				JMP EXIT_PADDLE_MOVIMENT
				
				CORRECT_RIGHT_PADDLE_UP_POSITION:
					MOV AX, WINDOW_BOUNDS
					MOV PADDLE_RIGHT_Y, AX
					JMP EXIT_PADDLE_MOVIMENT
			
			; Moves the right paddle down
			MOVE_RIGHT_PADDLE_DOWN:
				MOV AX, PADDLE_VELOCITY
				ADD PADDLE_RIGHT_Y, AX
			
				MOV AX, WINDOW_HEIGHT
				SUB AX, WINDOW_BOUNDS
				SUB AX, PADDLE_HEIGHT
				CMP PADDLE_RIGHT_Y, AX
				JG CORRECT_RIGHT_PADDLE_DOWN_POSITION
				JMP EXIT_PADDLE_MOVIMENT
				
				; Used to respect the window dimensions
				CORRECT_RIGHT_PADDLE_DOWN_POSITION:
					MOV PADDLE_RIGHT_Y, AX
					JMP EXIT_PADDLE_MOVIMENT
			
			EXIT_PADDLE_MOVIMENT:
				RET
			
				
	MOVE_PADDLES ENDP
	; =================================================================================================================
	
	
	; Draws user interface
	; =================================================================================================================
	DRAW_UI PROC NEAR
		; Daws the points of the left player (Player One)
		MOV AH, 02h                       ; -> Set Cursor Position
		MOV BH, 00h                       ; -> Set page number
		MOV DH, 04h                       ; -> Set row to be displayed
		MOV DL, 06h                       ; -> Set column to be displayed
		INT 10h
		
		MOV AH, 09h                       ; -> Writes the string
		LEA DX, PLAYER_ONE_POINTS_TEXT
		INT 21h
		
		
		; Daws the points of the right player (Player Two)
		MOV AH, 02h                       ; -> Set Cursor Position
		MOV BH, 00h                       ; -> Set page number
		MOV DH, 04h                       ; -> Set row to be displayed
		MOV DL, 1Fh                       ; -> Set column to be displayed
		INT 10h
		
		MOV AH, 09h                       ; -> Writes the string
		LEA DX, PLAYER_TWO_POINTS_TEXT
		INT 21h
	
		RET
	DRAW_UI ENDP
	; =================================================================================================================

	
	; Draws the paddles
	; =================================================================================================================
	DRAW_PADDLES PROC NEAR
	
		; Left Paddle
		MOV CX, PADDLE_LEFT_X             ; -> Sets the reference x position (column)
		MOV DX, PADDLE_LEFT_Y             ; -> Sets the reference y position (row)
		
		DRAW_PADDLES_LEFT:
			; Draws the pixel
			MOV AH, 0Ch                   ; -> Configuration to write the pixel
			MOV AL, 0Fh                   ; -> Chooses the pixel color (white)
			MOV BH, 00h                   ; -> Sets the page number
			INT 10h                       ; -> Executes the configuration
			
			; Evaluates the columns
			INC CX                        ; -> CX = CX + 1 (next column)
			MOV AX, CX                    ; -> Uses aux variable
			SUB AX, PADDLE_LEFT_X         ; -> AX = AX - PADDLE_LEFT_X
			CMP AX, PADDLE_WIDHT          ; -> Compares AX and PADDLE_WIDHT
			JNG DRAW_PADDLES_LEFT         ; -> If CMP result is "Not Greater" than go to DRAW_PADDLES_LEFT procedure else:
			
			; Evaluates the rows
			MOV CX, PADDLE_LEFT_X         ; -> Returns to the first "column"
			INC DX                        ; -> DX = DX + 1 (next row)
			MOV AX, DX                    ; -> Uses aux variable
			SUB AX, PADDLE_LEFT_Y         ; -> AX = AX - PADDLE_LEFT_Y
			CMP AX, PADDLE_HEIGHT         ; -> Compares AX and PADDLE_HEIGHT
			JNG DRAW_PADDLES_LEFT         ; -> If CMP result is "Not Greater" than go to DRAW_PADDLES_LEFT
			
		; Right Paddle
		MOV CX, PADDLE_RIGHT_X             ; -> Sets the reference x position (column)
		MOV DX, PADDLE_RIGHT_Y             ; -> Sets the reference y position (row)
		
		DRAW_PADDLES_RIGHT:
			; Draws the pixel
			MOV AH, 0Ch                   ; -> Configuration to write the pixel
			MOV AL, 0Fh                   ; -> Chooses the pixel color (white)
			MOV BH, 00h                   ; -> Sets the page number
			INT 10h                       ; -> Executes the configuration
			
			; Evaluates the columns
			INC CX                        ; -> CX = CX + 1 (next column)
			MOV AX, CX                    ; -> Uses aux variable
			SUB AX, PADDLE_RIGHT_X        ; -> AX = AX - PADDLE_RIGHT_X
			CMP AX, PADDLE_WIDHT          ; -> Compares AX and PADDLE_WIDHT
			JNG DRAW_PADDLES_RIGHT        ; -> If CMP result is "Not Greater" than go to DRAW_PADDLES_RIGHT procedure else:
			
			; Evaluates the rows
			MOV CX, PADDLE_RIGHT_X        ; -> Returns to the first "column"
			INC DX                        ; -> DX = DX + 1 (next row)
			MOV AX, DX                    ; -> Uses aux variable
			SUB AX, PADDLE_RIGHT_Y        ; -> AX = AX - PADDLE_RIGHT_Y
			CMP AX, PADDLE_HEIGHT         ; -> Compares AX and PADDLE_HEIGHT
			JNG DRAW_PADDLES_RIGHT        ; -> If CMP result is "Not Greater" than go to DRAW_PADDLES_RIGHT
			
		RET
	DRAW_PADDLES ENDP
	; =================================================================================================================
	
	
	; Resets the ball position
	; =================================================================================================================
	RESET_BALL_POSITION PROC NEAR
	
		MOV AX, ORIGINAL_X                ; -> Gets the original x position 
		MOV BALL_X, AX                    ; -> Resets the x postition
		
		MOV AX, ORIGINAL_Y                ; -> Gets the original y position 
		MOV BALL_Y, AX                    ; -> Resets the y postition
	
		RET
	RESET_BALL_POSITION ENDP
	; =================================================================================================================
	
	
	; Update points texts
	; =================================================================================================================
	UPDATE_PLAYER_ONE_TEXT_POINTS PROC NEAR
		XOR AX, AX
		MOV AL, PLAYER_ONE_POINTS

		ADD AL, 30h                       ; -> Converts the integer to ascii character
		
		MOV [PLAYER_ONE_POINTS_TEXT], AL
		
		RET
	UPDATE_PLAYER_ONE_TEXT_POINTS ENDP
	
	
	
	UPDATE_PLAYER_TWO_TEXT_POINTS PROC NEAR
		XOR AX, AX
		MOV AL, PLAYER_TWO_POINTS

		ADD AL, 30h                       ; -> Converts the integer to ascii character
		
		MOV [PLAYER_TWO_POINTS_TEXT], AL
		
		RET
		
		RET
	UPDATE_PLAYER_TWO_TEXT_POINTS ENDP
	; =================================================================================================================
	
	
CODE ENDS
; =====================================================================================================================
; =====================================================================================================================


END