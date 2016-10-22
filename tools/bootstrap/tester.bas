

;TESTER.PRG ==0401==
   10 print"{clr}pedisk tester{down}
   20 print"1. boot disk (init)
   30 print"2. select drive
   40 print"3. de-select drive
   50 print"4. step head out
   60 print"5. step head in
   70 print"6. head to track 0
   80 print"7. print track 0 flag
   81 print"8. print current track
   82 print"9. print write protect flag
   85 print
   90 print"0. re-print menu
   95 print"x. exit
  100 geta$:ifa$="x"then end
  105 if a$>"0" and a$<":" then print"["a$"] ";
  110 if a$="0" goto 10
  120 if a$="1" then sys59904
  130 if a$="2" then poke59648,9
  140 if a$="3" then poke59648,0
  150 if a$="4" then poke59776,99
  160 if a$="5" then poke59776,67
  170 if a$="6" then poke59776,11
  180 if a$="7" then print peek(59776)and4
  181 if a$="8" then printpeek(59777)
  182 if a$="9" then printpeek(59776)and64
  185 if a$>"0" anda$<"9" then print
  190 goto 100

