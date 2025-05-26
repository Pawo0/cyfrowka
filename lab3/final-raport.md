# Technika Cyfrowa - Sprawozdanie 3
## Projekt odtwarzacza MP3

### Autorzy
- Kacper Feliks
- Robert Raniszewski
- Paweł Czajczyk
- Mateusz Pawliczek

## Opis ćwiczenia

Proszę zaprojektować automat mogący posłużyć do sterowania jakimś prostym odtwarzaczem **plików muzycznych mp3.**

Układ powinien mieć następujące przyciski oraz odpowiadające im sygnały i wskaźniki:

- STOP
- PLAY
- NEXT
- PREVIOUS

oraz powinien posiadać **dwubitowe wyjście binarne** określające numer utworu.

## Założenia Projektu

Celem zadania było zaprojektowanie prostego układu MP3 sterowanego przez pojedynczy automat oraz cztery przyciski: `PLAY, STOP, NEXT, PREVIOUS`.

Przyjęto następujące założenia realizacyjne:

- Automat przechowuje informację o **aktualnie odtwarzanym utworze** oraz o tym, czy utwór jest **odtwarzany czy zatrzymany**.

- Zakłada się, że użytkownik **nigdy nie naciska więcej niż jednego przycisku jednocześnie** — w przypadku wykrycia wielu sygnałów wejściowych jednocześnie, układ nie podejmuje żadnej akcji.

- Naciśnięcie przycisku interpretowane jest jako **impuls trwający jeden cykl zegara** (impulsowy sygnał wysokiego poziomu, podobnie jak w przypadku typowego przycisku fizycznego).

- Dodatkowo, naciśnięcie przycisków `NEXT` lub `PREVIOUS` powoduje również wznowienie odtwarzania, jeśli wcześniej muzyka była zatrzymana.

## Projekt Automatu (Alternatywna Koncepcja)

W trakcie projektowania rozważaliśmy kilka możliwych podejść do realizacji zadania. Jedną z alternatywnych koncepcji było wykorzystanie **dwóch osobnych automatów**: jednego do obsługi odtwarzania muzyki, drugiego do zarządzania numerem utworu (ścieżkami).
### Automat do obsługi muzyki 
![image](./assets-new/schemat_alt_1.png)

### Automat do obsługi ścieżek
![image](./assets-new/schemat_alt_2.png)

Choć podejście to pozwalało na czytelne rozdzielenie funkcji, ostatecznie zrezygnowaliśmy z niego — zgodnie z treścią zadania wymagane było użycie **pojedynczego automatu**. W dalszej części opisujemy implementację, którą finalnie przyjęliśmy.

## Projekt automatu (finalna koncepcja)

W finalnej wersji projektu zdecydowaliśmy się na reprezentację stanu odtwarzacza MP3 za pomocą **trzebitowej liczby**. 

- **Najstarszy bit** (MSB) przechowuje informację o tym, czy muzyka jest aktualnie **odtwarzana (1)**, czy **zatrzymana (0)**.  
- **Dwa młodsze bity** odpowiadają za **numer aktualnego utworu** (od 0 do 3).

![image](./assets-new/schemat_bit.png)

Dzięki takiej strukturze automat posiada łącznie **8 unikalnych stanów**, które opisują zarówno status odtwarzania, jak i aktualny utwór. Przejścia między stanami są determinowane przez sygnały z przycisków: `PLAY`, `STOP`, `NEXT`, `PREVIOUS`.

Automat został zaprojektowany tak, aby:
- Wciśnięcie `NEXT` lub `PREVIOUS` powodowało przejście do odpowiedniego utworu.
- Jeżeli muzyka była zatrzymana, to po zmianie utworu **automatycznie następuje wznowienie odtwarzania**.
- Utwory tworzą **cykl zamknięty**, co oznacza możliwość przechodzenia z końca na początek i odwrotnie, np. `00 ➜ 11` oraz `11 ➜ 00`.

---

### Pełny schemat automatu:
![image](./assets-new/schemat_full.png)

### Przejścia dla przycisku `NEXT`:
![image](./assets-new/schemat_next.png)

### Przejścia dla przycisku `PREVIOUS`:
![image](./assets-new/schemat_prev.png)

## Koncepcja Schematu Układu

Korzystając z wcześniej przygotowanych projektów Automatu stworzyliśmy układ okreslający potrzebne nam komponenty oraz ich działanie. Jest to nic innego niż teoretyczny sposób na rozwiązanie zadania, który w następnych krokach zrealizowaliśmy. Schemat wygląda następująco:

### Konceptowy Układ z komponentami

![image](./assets-new/uklad_schemat.png)

### Wyjaśnienie działania układu

Wejścia `NEXT`, `PREV`, `PLAY`, `STOP` to po prostu **przyciski**, które w obecnej implementacji mają formę **przełączników dwustanowych** (mogą przyjmować wartość `0` lub `1`). Aby zasymulować rzeczywiste zachowanie przycisku (czyli krótkiego impulsu), zastosowaliśmy dodatkowy komponent — `INPUT PARSER`.

#### Komponent `INPUT PARSER`

Ten moduł odpowiada za przetwarzanie sygnałów wejściowych z przycisków i składa się z dwóch podkomponentów:

- **`IMPULSE DETECTOR`**  
  Odpowiada za konwersję sygnału trwale wysokiego (`1`) na **pojedynczy impuls**, który trwa maksymalnie **jeden cykl zegara**.

- **`LOGIC`**  
  Zapewnia, że **w danym cyklu aktywny może być tylko jeden przycisk**. W przypadku wykrycia więcej niż jednego aktywnego wejścia, żaden sygnał nie jest przekazywany dalej — zapobiega to niepożądanym reakcjom automatu.

#### Komponent `MP3 LOGIC`

Otrzymuje przetworzone sygnały z `INPUT PARSERA` i analizuje je, generując trzy sygnały sterujące: `T2`, `T1`, `T0`. Każdy z nich informuje, **czy dany bit stanu powinien zostać zmieniony**:
- `T2` — odnosi się do **najstarszego bitu** (odtwarzanie muzyki),
- `T1`, `T0` — odpowiadają za numer utworu (2-bitowy licznik).

#### Komponent `COUNTER`

Na podstawie sygnałów `T2`, `T1`, `T0`, licznik zmienia swój aktualny stan i generuje nowe wartości wyjściowe: `Q2`, `Q1`, `Q0`. Są to aktualne bity stanu automatu:
- `Q2` — informacja o tym, czy muzyka jest odtwarzana (`1`) czy zatrzymana (`0`),
- `Q1`, `Q0` — aktualny numer odtwarzanego utworu.

> Warto zauważyć, że cyfry w nazwach zmiennych `T` i `Q` oznaczają **pozycję bitu**:
> - `T2` i `Q2` — najstarszy bit (odtwarzanie),
> - `T1` i `Q1` — pierwszy bit numeru utworu,
> - `T0` i `Q0` — najmłodszy bit numeru utworu.

#### Wizualizacja wyjść

Sygnały `Q1` i `Q0`, reprezentujące numer utworu, są przesyłane do **wyświetlacza 4-bitowego**, z którego wykorzystujemy jedynie **dwa najmłodsze bity**.  
Sygnał `Q2`, informujący o stanie odtwarzania, steruje **diodą LED podpisaną `PLAYING`** — dioda świeci, gdy muzyka jest odtwarzana.

## Analiza logiki sterującej

Nasz układ ma dwa komponenty logiczne które wymagają analizy pojedyńczych wartości logicznych. Są to `INPUT PARSER ➜ LOGIC` oraz `MP3 LOGIC`. Najpierw przedstawimy analizę wartości logicznych `INPUT PARSERA`, ponieważ od niego zależą wartości logiczne otrzymane w `MP3 LOGIC`.

### INPUT PARSER ➜ LOGIC

Projektowanie tego komponentu rozpoczęliśmy od analizy tablicy wartości logicznych. Układ otrzymuje cztery sygnały wejściowe: `NEXT`, `PREVIOUS`, `PLAY` oraz `STOP`.

Założeniem działania komponentu `LOGIC` jest to, że **wyjście może być aktywne tylko wtedy, gdy dokładnie jeden z sygnałów wejściowych ma wartość `1`**. W przeciwnym wypadku, gdy aktywne są dwa lub więcej wejść, żadne wyjście nie zostaje wygenerowane.

#### Tabela wartości logicznych

![image](./assets-new/logika-input-parser.jpg)

Na podstawie analizy uzyskaliśmy następujące zależności logiczne dla sygnałów wyjściowych: `NEXT_O`, `PREV_O`, `PLAY_O`, `STOP_O`:

```
NEXT_O  = ¬(P + PL + ST) · N
PREV_O  = ¬(N + PL + ST) · P
PLAY_O  = ¬(N + P + ST) · PL
STOP_O  = ¬(N + P + PL) · ST
```

Gdzie:
- `N` = `NEXT`
- `P` = `PREVIOUS`
- `PL` = `PLAY`
- `ST` = `STOP`

> Równania można też przedstawić z użyciem operatora NAND lub NOR w zależności od dalszej implementacji w logice sprzętowej.  
> **W naszym projekcie zdecydowaliśmy się jednak na zastosowanie pełnych, nieupraszczanych wyrażeń logicznych** — co ułatwia ich analizę oraz implementację na etapie projektowania układu.



Ostateczne sygnały `NEXT_O`, `PREV_O`, `PLAY_O`, `STOP_O` są przekazywane dalej do komponentu `MP3 LOGIC`, który na ich podstawie decyduje o zmianie stanu odtwarzacza.

### MP3 LOGIC

Projektowanie tego komponentu rozpoczęliśmy od analizy tablicy wartości logicznych. Układ otrzymuje siedem sygnałów wejściowych:

- `Q2, Q1, Q0` – 3-bitowa liczba określająca **obecny stan odtwarzacza MP3**  
- `NEXT, PREV, PLAY, STOP` – sygnały wejściowe przekazane z komponentu **INPUT PARSER**

W celu uproszczenia projektu oraz zmniejszenia liczby rekordów analizowanych w tabelach prawdy, zdecydowaliśmy się na **pominięcie przypadków, w których więcej niż jeden przycisk wejściowy ma wartość `1`**.

Pominięcie to jest uzasadnione, ponieważ w działającym układzie taka sytuacja **nie może wystąpić** – komponent `INPUT PARSER` gwarantuje, że **aktywny może być tylko jeden sygnał wejściowy na raz**.

W tabeli prawdy zastosowano oznaczenia `AQ2, AQ1, AQ0`, które odpowiadają wartościom bitów stanu po zareagowaniu na naciśnięcie przycisku.

Opisane zostały również sekcje wystepujące w tabeli. Oznaczenie pod tytułem `Liczba, Przycisk` np `1 NEXT` opisuje stan czy muzyka gra i wciśnięty przycisk

Dla przejrzystości analiz, każda sekcja tabeli została oznaczona etykietą w formacie Liczba, Przycisk (np. 1 NEXT). Pierwszy człon informuje, czy muzyka była odtwarzana (1) lub zatrzymana (0), a drugi wskazuje, który przycisk został naciśnięty.

#### Logika dla `NEXT` i `PREV`:
![image](./assets-new/logika-mp3-next-prev.jpg)

#### Logika dla `PLAY` i `STOP`:
![image](./assets-new/logika-mp3-play-stop.jpg)

---

### Podział logiki MP3 na komponenty funkcjonalne

Aby uprościć proces projektowania oraz analizę logiczną, zdecydowaliśmy się podzielić logikę komponentu `MP3 LOGIC` na cztery osobne bloki odpowiadające każdemu z możliwych sygnałów wejściowych (`NEXT`, `PREV`, `PLAY`, `STOP`).

Każdy z tych bloków — oznaczonych jako `T_NEXT`, `T_PREV`, `T_PLAY`, `T_STOP` — jest aktywny **wyłącznie wtedy**, gdy odpowiadający mu sygnał wejściowy ma wartość `1`. Dzięki temu możemy osobno analizować i projektować logikę zmian bitów tylko dla jednego aktywnego przycisku, co znacząco upraszcza zarówno tablice Karnaugha, jak i późniejszą implementację układu.

W kolejnych podsekcjach przedstawiamy osobno logikę każdego z tych komponentów.

#### Logika `T_NEXT`

![image](./assets-new/mp3-logic-next.png)

#### Logika `T_PREV`

![image](./assets-new/mp3-logic-prev.png)

#### Logika `T_PLAY`

![image](./assets-new/mp3-logic-play.png)

#### Logika `T_STOP`

![image](./assets-new/mp3-logic-stop.png)

Każdy z powyższych komponentów generuje niezależnie sygnały wyjściowe `T2, T1, T0`, które odpowiadają za ewentualną zmianę odpowiednich bitów stanu (`Q2, Q1, Q0`). Ponieważ tylko jeden z komponentów może być aktywny w danym cyklu (zgodnie z działaniem `INPUT PARSER`), sygnały `T2, T1, T0` z każdego bloku są **łączone logiczną operacją OR**. 

W rezultacie końcowe wartości `T2, T1, T0` są wynikiem działania **jednego aktywnego bloku logicznego**, co upraszcza konstrukcję układu i umożliwia niezależne projektowanie każdego komponentu.

## Implementacja

Po zaprojektowaniu i analizie logiki sterującej, przeszliśmy do implementacji kompletnego układu odtwarzacza MP3. W tej części przedstawiamy strukturę całego systemu oraz sposób, w jaki poszczególne komponenty zostały połączone w spójną całość.

Realizacja zadania została wykonana w programie `MultiSim v14.2`
