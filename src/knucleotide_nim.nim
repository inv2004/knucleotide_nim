import sequtils
import strutils
import tables
import strformat

proc encode(c: char): byte =
  0b11 and c.byte shr 1

proc decode(b: int): char =
  case b
  of 0b00: 'A'
  of 0b01: 'C'
  of 0b10: 'T'
  of 0b11: 'G'
  else: '_'

func sh(a: var int, x: int, m: int) =
  a = m and (a shl 2) or x

func freq(input: seq[byte], len: int): CountTable[int] =
  result = initCountTable[int]()
  let mask = 1 shl (2 * len) - 1
  var a = 0
  for x in input[0..<len-1]:
    a.sh(x.int, mask)
  for x in input[(len-1)..input.high]:
    a.sh(x.int, mask)
    result.inc(a)

proc printStat1(ct: var CountTable[int]) =
  let total = ct.foldl(a+b)
  ct.sort()
  for k, v in ct:
    echo fmt"{decode(k)}: {(100 * v) / total:.3f}"
  echo()

proc printStat2(ct: var CountTable[int]) =
  let total = ct.foldl(a+b)
  ct.sort()
  for k, v in ct:
    echo fmt"{decode(k shr 2)}{decode(k and 0b11)}: {(100 * v) / total:.3f}"
  echo()

proc print(ct: CountTable[int], str: string) =
  let mask = 1 shl (2 * str.len) - 1
  var a = 0
  for x in str:
    a.sh(0b11 and (x.int shr 1), mask)
  echo ct[a], "\t", str


proc getSeq(key: string): seq[byte] =
  # let file = "knucleotide-input.txt".open()
  let file = "in250k.txt".open()
  var line = ""
  while file.readLine(line):
    if line.startsWith(key):
      break

  while file.readLine(line):
    result.add(line.mapIt(encode(it)))

proc calcS(input: seq[byte], s: string) =
  let len = s.len
  let f = freq(input, len)
  print(f, s)

proc calc() =
  let s = getSeq(">THREE")
  var f1 = freq(s, 1)
  printStat1(f1)
  var f2 = freq(s, 2)
  printStat2(f2)
  calcS(s, "GGT")
  calcS(s, "GGTA")
  calcS(s, "GGTATT")
  calcS(s, "GGTATTTTAATT")
  calcS(s, "GGTATTTTAATTTATAGT")

when isMainModule:
  calc()

