---
title: Cw 1 Cyfrowka

---
# Technika Cyfrowa -  Sprawozdanie z ćwiczenia nr 1

## Opis zadania
Bazując wyłącznie na bramkach NAND, proszę zaprojektować układ kombinacyjny realizujący transkoder trzybitowej liczby binarnej na układ graficzny emotikony wyświetlanej na szesnastu punktach, zgodnie z poniższym rysunkiem:
![cw1_1](https://hackmd.io/_uploads/B1EhF2F3Jl.png)

## Pomysł rozwiązania
Dla każdego możliwego wejścia trzybitowej liczby (czyli 8 możliwości) przypisujemy kolejny kolejne możliwe zestawy pikseli wyświetlających emotikony. Po czym każdego kolejnego piksela rozwiązujemy Tablice Karnaugh, aby poznać wzór na ten konkretny układ pikseli.

## Tabela pokazująca jak dla zadanego wejscia zachowywują się konkretne piksele
(Numeracja pikseli kolumnowo)
| ABC | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 | 16 |
|-----|---|---|---|---|---|---|---|---|---|----|----|----|----|----|----|----|
| 000 | 1 | 0 | 0 | 1 | 0 | 0 | 1 | 1 | 0 | 0  | 1  | 1  | 1  | 0  | 0  | 1  |
| 001 | 1 | 0 | 0 | 1 | 0 | 0 | 1 | 0 | 0 | 0  | 1  | 0  | 1  | 0  | 0  | 1  |
| 010 | 1 | 0 | 1 | 0 | 0 | 0 | 1 | 0 | 0 | 0  | 1  | 0  | 1  | 0  | 1  | 0  |
| 011 | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0  | 1  | 0  | 1  | 0  | 0  | 0  |
| 100 | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 1 | 0 | 0  | 1  | 1  | 1  | 0  | 0  | 0  |
| 101 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0  | 0  | 1  | 1  | 0  | 0  | 0  |
| 110 | 1 | 0 | 1 | 0 | 0 | 0 | 0 | 1 | 0 | 0  | 0  | 1  | 1  | 0  | 1  | 0  |
| 111 | 1 | 0 | 1 | 0 | 0 | 0 | 1 | 1 | 0 | 0  | 1  | 1  | 1  | 0  | 1  | 0  |


Możemy zauważyć, że grupy pikseli 1-4 i 13-16 oraz 5-8 i 9-12 sa takie, co sugeruje nam, że zwracane emotikony są zawsze symetryczne wzgledem osi y. Więc przy dalszych obliczeniach, możemy rozwiązać jedną tablice dla pary pikseli.



## Tablice Karnaugh
Dla każdego piksele szukamy formuły która go określa, a następnie przekształcamy wynik tak, żeby przedstawić go za pomocą samych bramek NAND
Użyjemy do tego przejść:
- A' = A nand A
- A * B = (A nand B) nand (A nand B)
- A + B = (A nand A) nand (B nand B)
- ### Dla pikseli 1 i 13
| AB/C | 0  | 1 |
|------|----|---|
| 0 0  | 1  | 1 |
| 0 1  | 1  | 1 |
| 1 1  | 1  | 1 |
| 1 0  | 1  | 1 |

Y = 1

- ### Dla pikseli 2, 14, 5, 9, 6, 10
| AB/C | 0  | 1 |
|------|----|---|
| 0 0  | 0  | 0 |
| 0 1  | 0  | 0 |
| 1 1  | 0  | 0 |
| 1 0  | 0  | 0 |

Y = 0

- ### Dla pikseli 3 i 15
| AB/C | 0  | 1 |
|------|----|---|
| 0 0  | 0  | 0 |
| 0 1  | 1  | 0 |
| 1 1  | 1  | 1 |
| 1 0  | 0  | 0 |

Y = BC' + AB = 
B(C nand C) + AB = 
((B nand (C nand C)) nand (B nand (C nand C))) + ((A nand B) nand (A nand B)) =
**(((B nand (C nand C)) nand (B nand (C nand C))) nand ((B nand (C nand C)) nand (B nand (C nand C)))) nand (((A nand B) nand (A nand B)) nand ((A nand B) nand (A nand B)))**

- ### Dla pikseli 4 i 16

| AB/C | 0  | 1 |
|------|----|---|
| 0 0  | 1  | 1 |
| 0 1  | 0  | 0 |
| 1 1  | 0  | 0 |
| 1 0  | 0  | 0 |

Y = A'B' = 
(A nand A) (B nand B) =
**(((A nand A) nand (B nand B)) nand (A nand A) nand (B nand B))**

- ### Dla pikseli 7 i 11

| AB/C | 0  | 1 |
|------|----|---|
| 0 0  | 1  | 1 |
| 0 1  | 1  | 1 |
| 1 1  | 0  | 1 |
| 1 0  | 1  | 0 |

Y = A' + CB + C'B' = 
(A nand A) + ((C nand B) nand (C nand B)) + (((C nand C) nand (B nand B)) nand ((C nand C) nand (B nand B))) = 
(A nand ((C nand B) nand (C nand B) nand (C nand B) nand (C nand B))) + (((C nand C) nand (B nand B)) nand ((C nand C) nand (B nand B))) =
**((A nand ((C nand B) nand (C nand B) nand (C nand B) nand (C nand B))) nand (A nand ((C nand B) nand (C nand B) nand (C nand B) nand (C nand B))) nand ((((C nand C) nand (B nand B)) nand ((C nand C) nand (B nand B))) nand (((C nand C) nand (B nand B)) nand ((C nand C) nand (B nand B)))))**

- ### Dla pikseli 8 i 12

| AB/C | 0  | 1 |
|------|----|---|
| 0 0  | 1  | 0 |
| 0 1  | 0  | 0 |
| 1 1  | 1  | 1 |
| 1 0  | 1  | 1 |

Y = A + C'B' =
A + (C nand C)(B nand B) =
A + ((C nand C) nand (B nand B)) nand ((C nand C) nand (B nand B)) =
**(A nand A) nand (((C nand C) nand (B nand B)) nand ((C nand C) nand (B nand B)) nand ((C nand C) nand (B nand B)) nand ((C nand C) nand (B nand B)))**

## Dla każdej pary pikseli tworzymy jego bramke w programie Multisim

- 3 i 15
 ![obraz](https://hackmd.io/_uploads/rySGETYn1e.png)

- 4 i 16
![obraz](https://hackmd.io/_uploads/BkXN4aY2yl.png)

- 7 i 11
![obraz](https://hackmd.io/_uploads/B1OHVTt3kx.png)

- 8 i 12
![obraz](https://hackmd.io/_uploads/ByXPN6tnJx.png)

1 i 13 jest stale podłączony do źródła zasilania ponieważ zawsze się świecą, a wszystkie pozostałe podłączamy do uziemienia, aby uniknąć zakłuceń z powodu "antenek"

## Stworzone bramki łączymy teraz w jeden spójny podukład
![obraz](https://hackmd.io/_uploads/HJeUBTK2Je.png)


## Układ testujący
Do układu załączyliśmy analizator stanu, więc możemy manualnie sprawdzić, czy dla konkretnych wejsc, wyjscie jest takie jak oczekujemy.
![obraz](https://hackmd.io/_uploads/SyOMLTFhke.png)

Przykładowe wyniki na analizatorze stanu

![obraz](https://hackmd.io/_uploads/BJmkDpK3yg.png)
## Zautomatyzowany układ sprawdzający na hali produkcyjnej
![image](https://hackmd.io/_uploads/HkA6qolTJx.png)



Generator słów wysyła odpowiedni sygnał wejściowy wraz z sygnałem wyjściowym, kolejno przechodząc przez wszystkie możliwe warianty.
![image](https://hackmd.io/_uploads/BkdZ3nn3Jg.png)
Następnie wyniki są porównywane z wynikami układu testowanego za pomocą bramek XOR. Jeśli zostanie wykryty błąd, przerzutnik go zapisuje i wysyła sygnał do generatora słów, aby zatrzymać testowanie, jednocześnie zapalając na stałe czerwoną lampkę.
![image](https://hackmd.io/_uploads/B1Gn5olTke.png)





## Zastowanie

Przykładowe zastosowanie przedstawionego układu to wsparcie osób z paraliżem twarzy w wyrażaniu emocji w sposób niewerbalny, co ułatwi im codzienne funkcjonowanie w społeczeństwie. Projekt można powiązać z programami dofinansowania, co stwarza możliwość uzyskania środków na rozwój oraz potencjalnej współpracy z instytucjami publicznymi w ramach spółki państwowej.

![image](https://hackmd.io/_uploads/r1Y-Gon3kg.png)
