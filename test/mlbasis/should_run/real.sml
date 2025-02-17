val == = Real.==;
infix 4 ==;
(* print ("radix = " ^ Int.toString Real.radix ^ "\n"); *)
(* print ("precision = " ^ Int.toString Real.precision ^ "\n"); *)
print ("maxFinite ... " ^ (if Real.maxFinite == 0x1.ffff_ffff_ffff_fp1023 then "OK" else "mismatch") ^ "\n");
print ("minPos ... " ^ (if Real.minPos == 0x1p~1074 then "OK" else "mismatch") ^ "\n");
print ("minNormalPos ... " ^ (if Real.minNormalPos == 0x1p~1022 then "OK" else "mismatch") ^ "\n");
val true = Real.posInf > Real.maxFinite;
val true = Real.negInf < ~Real.maxFinite;
fun isPositiveZero x = x == 0.0 andalso not (Real.signBit x)
fun isNegativeZero x = x == 0.0 andalso Real.signBit x
fun checkZero x = case (isPositiveZero x, isNegativeZero x) of
                      (true, false) => "positive zero"
                    | (false, true) => "negative zero"
                    | (false, false) => "not zero"
                    | (true, true) => "invalid";
fun sameValue (x, y) = if x == 0.0 andalso y == 0.0 then
                           Real.signBit x = Real.signBit y
                       else
                           x == y orelse (Real.isNan x andalso Real.isNan y);
List.app (fn (s, v) => print (s ^ ": " ^ checkZero v ^ "\n"))
         [("0.0", 0.0)
         ,("~0.0", ~0.0)
         ,("~ 0.0", ~ 0.0)
         ,("1.0/posInf", 1.0 / Real.posInf)
         ,("1.0/negInf", 1.0 / Real.negInf)
         ,("realFloor 0.5", Real.realFloor 0.5)
         ,("realFloor 0.0", Real.realFloor 0.0)
         ,("realFloor ~0.0", Real.realFloor ~0.0)
         ,("realCeil ~0.5", Real.realCeil ~0.5)
         ,("realCeil 0.0", Real.realCeil 0.0)
         ,("realCeil ~0.0", Real.realCeil ~0.0)
         ,("realTrunc 0.5", Real.realTrunc 0.5)
         ,("realTrunc ~0.5", Real.realTrunc ~0.5)
         ,("realTrunc 0.0", Real.realTrunc 0.0)
         ,("realTrunc ~0.0", Real.realTrunc ~0.0)
         ,("realRound 0.25", Real.realRound 0.25)
         ,("realRound ~0.25", Real.realRound ~0.25)
         ,("realRound 0.5", Real.realRound 0.5)
         ,("realRound ~0.5", Real.realRound ~0.5)
         ,("realRound 0.0", Real.realRound 0.0)
         ,("realRound ~0.0", Real.realRound ~0.0)
         ,("abs 0.0", abs 0.0)
         ,("abs ~0.0", abs ~0.0)
         ,("Real.abs 0.0", Real.abs 0.0)
         ,("Real.abs ~0.0", Real.abs ~0.0)
         ];
List.app (fn (s, x, { round, floor, ceil, trunc, abs }) =>
             ( let val y = Real.realRound x
                   val z = round
               in if sameValue (y, z) then
                      print ("realRound " ^ s ^ ": OK\n")
                  else
                      print ("realRound " ^ s ^ ": mismatch (" ^ Real.toString y ^ " vs " ^ Real.toString z ^ ")\n")
               end
             ; let val y = Real.realFloor x
                   val z = floor
               in if sameValue (y, z) then
                      print ("realFloor " ^ s ^ ": OK\n")
                  else
                      print ("realFloor " ^ s ^ ": mismatch (" ^ Real.toString y ^ " vs " ^ Real.toString z ^ ")\n")
               end
             ; let val y = Real.realCeil x
                   val z = ceil
               in if sameValue (y, z) then
                      print ("realCeil " ^ s ^ ": OK\n")
                  else
                      print ("realCeil " ^ s ^ ": mismatch (" ^ Real.toString y ^ " vs " ^ Real.toString z ^ ")\n")
               end
             ; let val y = Real.realTrunc x
                   val z = trunc
               in if sameValue (y, z) then
                      print ("realTrunc " ^ s ^ ": OK\n")
                  else
                      print ("realTrunc " ^ s ^ ": mismatch (" ^ Real.toString y ^ " vs " ^ Real.toString z ^ ")\n")
               end
             ; let val y = Real.abs x
                   val z = abs
               in if sameValue (y, z) then
                      print ("abs " ^ s ^ ": OK\n")
                  else
                      print ("abs " ^ s ^ ": mismatch (" ^ Real.toString y ^ " vs " ^ Real.toString z ^ ")\n")
               end
             )
         )
         [("negInf", Real.negInf, { round = Real.negInf, floor = Real.negInf, ceil = Real.negInf, trunc = Real.negInf, abs = Real.posInf })
         ,("~maxFinite", ~Real.maxFinite, { round = ~Real.maxFinite, floor = ~Real.maxFinite, ceil = ~Real.maxFinite, trunc = ~Real.maxFinite, abs = Real.maxFinite })
         ,("~3.5", ~3.5, { round = ~4.0, floor = ~4.0, ceil = ~3.0, trunc = ~3.0, abs = 3.5 })
         ,("~3.25", ~3.25, { round = ~3.0, floor = ~4.0, ceil = ~3.0, trunc = ~3.0, abs = 3.25 })
         ,("~3.0", ~3.0, { round = ~3.0, floor = ~3.0, ceil = ~3.0, trunc = ~3.0, abs = 3.0 })
         ,("~2.75", ~2.75, { round = ~3.0, floor = ~3.0, ceil = ~2.0, trunc = ~2.0, abs = 2.75 })
         ,("~2.5", ~2.5, { round = ~2.0, floor = ~3.0, ceil = ~2.0, trunc = ~2.0, abs = 2.5 })
         ,("~2.25", ~2.25, { round = ~2.0, floor = ~3.0, ceil = ~2.0, trunc = ~2.0, abs = 2.25 })
         ,("~2.0", ~2.0, { round = ~2.0, floor = ~2.0, ceil = ~2.0, trunc = ~2.0, abs = 2.0 })
         ,("~1.75", ~1.75, { round = ~2.0, floor = ~2.0, ceil = ~1.0, trunc = ~1.0, abs = 1.75 })
         ,("~1.5", ~1.5, { round = ~2.0, floor = ~2.0, ceil = ~1.0, trunc = ~1.0, abs = 1.5 })
         ,("~1.25", ~1.25, { round = ~1.0, floor = ~2.0, ceil = ~1.0, trunc = ~1.0, abs = 1.25 })
         ,("~1.0", ~1.0, { round = ~1.0, floor = ~1.0, ceil = ~1.0, trunc = ~1.0, abs = 1.0 })
         ,("~0.75", ~0.75, { round = ~1.0, floor = ~1.0, ceil = ~0.0, trunc = ~0.0, abs = 0.75 })
         ,("~0.5", ~0.5, { round = ~0.0, floor = ~1.0, ceil = ~0.0, trunc = ~0.0, abs = 0.5 })
         ,("~0.25", ~0.25, { round = ~0.0, floor = ~1.0, ceil = ~0.0, trunc = ~0.0, abs = 0.25 })
         ,("~minNormalPos", ~Real.minNormalPos, { round = ~0.0, floor = ~1.0, ceil = ~0.0, trunc = ~0.0, abs = Real.minNormalPos })
         ,("~minPos", ~Real.minPos, { round = ~0.0, floor = ~1.0, ceil = ~0.0, trunc = ~0.0, abs = Real.minPos })
         ,("~0.0", ~0.0, { round = ~0.0, floor = ~0.0, ceil = ~0.0, trunc = ~0.0, abs = 0.0 })
         ,("0.0", 0.0, { round = 0.0, floor = 0.0, ceil = 0.0, trunc = 0.0, abs = 0.0 })
         ,("minPos", Real.minPos, { round = 0.0, floor = 0.0, ceil = 1.0, trunc = 0.0, abs = Real.minPos })
         ,("minNormalPos", Real.minNormalPos, { round = 0.0, floor = 0.0, ceil = 1.0, trunc = 0.0, abs = Real.minNormalPos })
         ,("0.25", 0.25, { round = 0.0, floor = 0.0, ceil = 1.0, trunc = 0.0, abs = 0.25 })
         ,("0.5", 0.5, { round = 0.0, floor = 0.0, ceil = 1.0, trunc = 0.0, abs = 0.5 })
         ,("0.75", 0.75, { round = 1.0, floor = 0.0, ceil = 1.0, trunc = 0.0, abs = 0.75 })
         ,("1.0", 1.0, { round = 1.0, floor = 1.0, ceil = 1.0, trunc = 1.0, abs = 1.0 })
         ,("1.25", 1.25, { round = 1.0, floor = 1.0, ceil = 2.0, trunc = 1.0, abs = 1.25 })
         ,("1.5", 1.5, { round = 2.0, floor = 1.0, ceil = 2.0, trunc = 1.0, abs = 1.5 })
         ,("1.75", 1.75, { round = 2.0, floor = 1.0, ceil = 2.0, trunc = 1.0, abs = 1.75 })
         ,("2.0", 2.0, { round = 2.0, floor = 2.0, ceil = 2.0, trunc = 2.0, abs = 2.0 })
         ,("2.25", 2.25, { round = 2.0, floor = 2.0, ceil = 3.0, trunc = 2.0, abs = 2.25 })
         ,("2.5", 2.5, { round = 2.0, floor = 2.0, ceil = 3.0, trunc = 2.0, abs = 2.5 })
         ,("2.75", 2.75, { round = 3.0, floor = 2.0, ceil = 3.0, trunc = 2.0, abs = 2.75 })
         ,("3.0", 3.0, { round = 3.0, floor = 3.0, ceil = 3.0, trunc = 3.0, abs = 3.0 })
         ,("3.25", 3.25, { round = 3.0, floor = 3.0, ceil = 4.0, trunc = 3.0, abs = 3.25 })
         ,("3.5", 3.5, { round = 4.0, floor = 3.0, ceil = 4.0, trunc = 3.0, abs = 3.5 })
         ,("maxFinite", Real.maxFinite, { round = Real.maxFinite, floor = Real.maxFinite, ceil = Real.maxFinite, trunc = Real.maxFinite, abs = Real.maxFinite })
         ,("posInf", Real.posInf, { round = Real.posInf, floor = Real.posInf, ceil = Real.posInf, trunc = Real.posInf, abs = Real.posInf })
         ,let val NaN = 0.0 / 0.0
          in ("NaN", NaN, { round = NaN, floor = NaN, ceil = NaN, trunc = NaN, abs = NaN })
          end
         ];
