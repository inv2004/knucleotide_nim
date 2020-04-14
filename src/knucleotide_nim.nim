import sequtils
import strutils
import tables
import strformat
import times
import hashes
import threadpools/threadpool_simple

proc hash*(x: uint64): Hash {.inline.} =
  Hash(x) * Hash(0x7a48d7c544ffa2af)

proc encode(c: char): byte {.inline.} =
  0b11 and c.byte shr 1

proc decode(b: uint64): char =
  case b.int
  of 0b00: 'A'
  of 0b01: 'C'
  of 0b10: 'T'
  of 0b11: 'G'
  else: '_'

func sh(a: var uint64, x: byte, m: uint64) =
  a = m and (a shl 2) or x

proc freq(input: seq[byte], len: int): CountTable[uint64] =
  result = initCountTable[uint64]()
  let mask = 1.uint64 shl (2 * len) - 1
  var a = 0.uint64
  for x in input[0..<len-1]:
    a.sh(x, mask)
  for x in input[(len-1)..input.high]:
    a.sh(x, mask)
    result.inc(a)

proc printStat1(ct: var CountTable[uint64]) =
  var total = 0
  for _, v in ct:
    total += v
  ct.sort()
  for k, v in ct:
    echo fmt"{decode(k)}: {(100 * v) / total:.3f}"
  echo()

proc printStat2(ct: var CountTable[uint64]) =
  var total = 0
  for _, v in ct:
    total += v
  ct.sort()
  for k, v in ct:
    echo fmt"{decode(k shr 2)}{decode(k and 0b11)}: {(100 * v) / total:.3f}"
  echo()

proc print(ct: CountTable[uint64], str: string) =
  let mask = 1.uint64 shl (2 * str.len) - 1
  var a: uint64 = 0
  for x in str:
    a.sh(encode(x), mask)
  echo ct[a], "\t", str

proc getSeq(): seq[byte] =
  result = newSeqOfCap[byte](125000000)
  # let file = "knucleotide-input.txt".open()
  # let file = "in250k.txt".open()
  let file = "in25m.txt".open()
  var line = newStringOfCap(256000)
  while file.readLine(line):
    if line.startsWith(">THREE"):
      break

  while file.readLine(line):
    result.add(line.mapIt(encode(it)))

proc calcS(input: seq[byte], s: string) =
  let f = freq(input, s.len)
  print(f, s)

proc calc() =
  let s = getSeq()
  let fl = [18, 12, 6, 4, 3, 2, 1]
  var res = newSeq[FlowVar[CountTable[uint64]]](fl.len)
  for i in 0..fl.high:
    res[i] = spawn freq(s, fl[i])
  sync()
  var r6 = ^res[6]
  printStat1(r6)
  var r5 = ^res[5]
  printStat2(r5)
  var r4 = ^res[4]
  print(r4, "GGT")
  var r3 = ^res[3]
  print(r3, "GGTA")
  var r2 = ^res[2]
  print(r2, "GGTATT")
  var r1 = ^res[1]
  print(r1, "GGTATTTTAATT")
  var r0 = ^res[0]
  print(r0, "GGTATTTTAATTTATAGT")

proc calc1() =
  var time = cpuTime()
  let s = getSeq()
  echo cpuTime() - time
  time = cpuTime()
  let f = freq(s, 18)
  print(f, "GGTATTTTAATTTATAGT")
  echo cpuTime() - time

when isMainModule:
  calc1()

