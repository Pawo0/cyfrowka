---
title: Cw 1 Cyfrowka

---

# Technika Cyfrowa -  Sprawozdanie z ćwiczenia nr 1

## Opis zadania
Bazując wyłącznie na bramkach NAND, proszę zaprojektować układ kombinacyjny realizujący transkoder trzybitowej liczby binarnej na układ graficzny emotikony wyświetlanej na szesnastu punktach, zgodnie z poniższym rysunkiem:
![cw1_1](https://hackmd.io/_uploads/B1EhF2F3Jl.png)

## Pomysł rozwiązania
Pierwsze co możemy zauważyć to to, że wszystkie wyświetlane emotikony są symetryczne, więc do naszych obliczeń możemy uwzględnić tylko połowe układu.
Następnie dla każdego możliwego wejścia trzybitowej liczby (czyli 8 możliwości) przypisujemy kolejny kolejne możliwe emotikony. Po czym każdego kolejnego piksela rozwiązujemy Tablice Karnaugh, aby poznać wzór na taki układ pikseli.

## Tabela pokazująca jak dla zadanego wejscia zachowywują się konkretne piksele
(Numeracja pikseli kolumnowo)
| A B C | 1/13 | 2/14 | 3/15 | 4/16 | 5/9 | 6/10 | 7/11 | 8/12 |
|-------|------|------|------|------|-----|------|------|------|
| 0 0 0 | 1    | 0    | 0    | 1    | 0   | 0    | 1    | 1    |
| 0 0 1 | 1    | 0    | 0    | 1    | 0   | 0    | 1    | 0    |
| 0 1 0 | 1    | 0    | 1    | 0    | 0   | 0    | 1    | 0    |
| 0 1 1 | 1    | 0    | 0    | 0    | 0   | 0    | 1    | 0    |
| 1 0 0 | 1    | 0    | 0    | 0    | 0   | 0    | 1    | 1    |
| 1 0 1 | 1    | 0    | 0    | 0    | 0   | 0    | 0    | 1    |
| 1 1 0 | 1    | 0    | 1    | 0    | 0   | 0    | 0    | 1    |
| 1 1 1 | 1    | 0    | 1    | 0    | 0   | 0    | 1    | 1    |

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
![obraz](https://hackmd.io/_uploads/SyOMLTFhke.png)

Przykładowe wyniki na analizatorze stanu

![obraz](https://hackmd.io/_uploads/BJmkDpK3yg.png)
![image](https://hackmd.io/_uploads/HJrJ3n32yl.png)
![image](https://hackmd.io/_uploads/BkdZ3nn3Jg.png)



## Zastowanie

Przykładowe zastosowanie przedstawionego układu to wsparcie osób z paraliżem twarzy w wyrażaniu emocji w sposób niewerbalny, co ułatwi im codzienne funkcjonowanie w społeczeństwie. Projekt można powiązać z programami dofinansowania, co stwarza możliwość uzyskania środków na rozwój oraz potencjalnej współpracy z instytucjami publicznymi w ramach spółki państwowej.

![image](https://hackmd.io/_uploads/r1Y-Gon3kg.png)
