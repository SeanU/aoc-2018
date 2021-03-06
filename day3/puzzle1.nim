import os
import strutils
import parseutils

type 
    Fabric = tuple[ size: int, slots: seq[seq[int]] ]
    Claim = tuple[id: int, x: int, y: int, width: int, height: int]

proc makeSlots(size: int): seq[seq[int]] =
    newSeq(result, size)
    for i in 0..<size:
        result[i] = newSeq[int](size)

proc newFabric(size: int): Fabric = (size: size, slots: makeSlots(size))

proc double(fabric: var Fabric): void =
    let oldSize = fabric.size
    fabric.size = oldSize * 2
    echo "Growing fabric from $1 to $2" % [$oldSize, $fabric.size]
    setlen(fabric.slots, fabric.size)

    for i in 0..<oldSize:
        setlen(fabric.slots[i], fabric.size)
    
    for i in oldSize..<fabric.size:
        fabric.slots[i] = newSeq[int](fabric.size)

proc countOverlaps(fabric: Fabric): int =
    for x in 0..<fabric.size:
        for y in 0..<fabric.size:
            if fabric.slots[x][y] > 1:
                inc(result)

proc parseClaim(line: string): Claim =
    var id, cursor: int
    var x, y, width, height: Natural

    cursor = cursor + skipWhile(line, {'#'}, cursor)
    cursor = cursor + parseInt(line, id, cursor)
    cursor = cursor + skipWhile(line, {' ', '@'} , cursor)
    cursor = cursor + parseInt(line, x, cursor)
    cursor = cursor + skipWhile(line, {','}, cursor)
    cursor = cursor + parseInt(line, y, cursor)
    cursor = cursor + skipWhile(line, {':', ' '}, cursor)
    cursor = cursor + parseInt(line, width, cursor)
    cursor = cursor + skipWhile(line, {'x'}, cursor)
    cursor = cursor + parseInt(line, height, cursor)

    (id, x, y, width, height)

proc size(claim: Claim): int =
    max(claim.x + claim.width, claim.y + claim.height)

proc makeFit(fabric: var Fabric, claim: Claim): void =
    while(claim.size >= fabric.size):
        fabric.double()

proc layClaim(claim: Claim, fabric: var Fabric): void =
    for x in claim.x..<(claim.x + claim.width):
        for y in claim.y..<(claim.y + claim.height):
            inc(fabric.slots[x][y])
        
proc calcOverlap(file: string): int =
    var fabric = newFabric(1)

    for line in file.lines:
        let claim = parseClaim(line)
        makeFit(fabric, claim)
        claim.layClaim(fabric)

    return fabric.countOverlaps()

let input = commandLineParams()[0]
echo "overlap: $1" % [$calcOverlap(input)]