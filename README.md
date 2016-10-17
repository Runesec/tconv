# tconv

A wrapper written in bash to assist with conversion tasks that are common during CTF competitions.
 * ASCII to Hexadecimal
 * ASCII to Decimal
 * Decimal to ASCII
 * Decimal to Hexadecimal
 * Hexadecimal to ASCII
 * Hexadecimal to Decimal
 * Reverse the order of bytes, helpful for reversing the endianness
<br><br>

**HISTORY**

tconv was developed during our preparation for the *Pentest Cyprus 2.0 (2016)* CTF competition because we couldn't find a single tool that could perform the above tasks.
<br><br>

**USAGE**
  ```
    Usage: ./tconv.sh -m atoh -i some_text
      -m, --mode      Mode, available modes:
                      rev  (Reverse Endianness)
                      atoh (ASCII to Hex)
                      atod (ASCII to Decimal)
                      dtoa (Decimal to ASCII)
                      dtoh (Decimal to Hex)
                      htoa (Hex to ASCII)
                      htod (Hex to Decimal)
                      atoA (ASCII to All; hex and decimal)
                      dtoA (Decimal to All; ASCII and hex)
                      htoA (Hex to All; ASCII and decimal)
      -i, --input     The ASCII/decimal/hex value you want to convert
      -h, --help      Show help and exit

  To read from a file, use: ./tconv.sh -m atoh -i $(cat test.txt)
  ```
