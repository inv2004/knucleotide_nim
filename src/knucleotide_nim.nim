import sequtils
import strutils
import tables

proc encode(c: char): byte =
  (c.uint8 and 0b110'u8) shr 1

proc genFreq(input: seq[byte], frame: uint8): CountTable =
  dispose

proc getSeq(key: TaintedString): seq[byte] =
  let file = "knucleotide-input.txt".open()
  var line: TaintedString
  while file.readLine(line):
    if line.startsWith(key):
      break

  while file.readLine(line):
    result.add(line.mapIt(encode(it)))


proc calc() =
  let s = getSeq(">THREE")
  echo $s

when isMainModule:
  calc()

