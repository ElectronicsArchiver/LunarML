structure JsSyntax = struct
datatype ObjectKey = IntKey of int
                   | StringKey of string
datatype Id = PredefinedId of string
            | UserDefinedId of TypedSyntax.VId
structure IdKey = struct
type ord_key = Id
fun compare (PredefinedId x, PredefinedId y) = String.compare (x, y)
  | compare (PredefinedId _, UserDefinedId _) = LESS
  | compare (UserDefinedId _, PredefinedId _) = GREATER
  | compare (UserDefinedId x, UserDefinedId y) = TypedSyntax.VIdKey.compare (x, y)
end : ORD_KEY
structure IdSet = RedBlackSetFn (IdKey)
structure IdSet = struct
(* compatibility with older smlnj-lib *)
open IdSet
val toList = foldr (op ::) []
open IdSet
end
structure IdMap = RedBlackMapFn (IdKey)
datatype JsConst = Null
                 | False
                 | True
                 | Numeral of string (* integer *)
                 | WideString of int vector
fun asciiStringAsIntVector s = Vector.map Char.ord (Vector.fromList (String.explode s))
fun asciiStringAsWide s = WideString (asciiStringAsIntVector s)
datatype BinaryOp = PLUS
                  | MINUS
                  | TIMES
                  | DIV
                  | MOD
                  | BITAND
                  | BITXOR
                  | BITOR
                  | RSHIFT (* >> *)
                  | LSHIFT (* << *)
                  | URSHIFT (* >>> *)
                  | LT
                  | LE
                  | GT
                  | GE
                  | EQUAL (* === *)
                  | NOTEQUAL (* !== *)
                  | LAXEQUAL (* == *)
                  | NOTLAXEQUAL (* != *)
                  | AND (* && *)
                  | OR (* || *)
                  | ASSIGN
                  | INSTANCEOF
                  | IN
                  | EXP (* ** *)
datatype UnaryOp = VOID
                 | TYPEOF
                 | TONUMBER (* unary + *)
                 | NEGATE
                 | BITNOT
                 | NOT
datatype Exp = ConstExp of JsConst
             | ThisExp
             | VarExp of Id
             | ObjectExp of (ObjectKey * Exp) vector
             | ArrayExp of Exp vector
             | CallExp of Exp * Exp vector
             | MethodExp of Exp * string * Exp vector (* method name must be ASCII Identifier *)
             | NewExp of Exp * Exp vector
             | FunctionExp of Id vector * Block
             | BinExp of BinaryOp * Exp * Exp
             | UnaryExp of UnaryOp * Exp
             | IndexExp of Exp * Exp
             | CondExp of Exp * Exp * Exp (* exp1 ? exp2 : exp3 *)
     and Stat = VarStat of (TypedSyntax.VId * Exp option) vector (* must not be empty *)
              | ExpStat of Exp
              | IfStat of Exp * Block * Block
              | ReturnStat of Exp option
              | TryCatchStat of Block * TypedSyntax.VId * Block
              | ThrowStat of Exp
withtype Block = Stat vector

val UndefinedExp = VarExp (PredefinedId "undefined")
fun ToInt32Exp exp = BinExp (BITOR, exp, ConstExp (Numeral "0"))
fun ToUint32Exp exp = BinExp (URSHIFT, exp, ConstExp (Numeral "0"))
fun AssignStat (lhs, rhs) = ExpStat (BinExp (ASSIGN, lhs, rhs))
end;

structure JsWriter = struct
fun smlNameToJsChar #"_" = "_"
  | smlNameToJsChar #"'" = "$PRIME"
  | smlNameToJsChar #"!" = "$EXCLAM"
  | smlNameToJsChar #"%" = "$PERCENT"
  | smlNameToJsChar #"&" = "$AMPER"
  | smlNameToJsChar #"$" = "$DOLLAR"
  | smlNameToJsChar #"#" = "$HASH"
  | smlNameToJsChar #"+" = "$PLUS"
  | smlNameToJsChar #"-" = "$MINUS"
  | smlNameToJsChar #"/" = "$SLASH"
  | smlNameToJsChar #":" = "$COLON"
  | smlNameToJsChar #"<" = "$LT"
  | smlNameToJsChar #"=" = "$EQ"
  | smlNameToJsChar #">" = "$GT"
  | smlNameToJsChar #"?" = "$QUESTION"
  | smlNameToJsChar #"@" = "$AT"
  | smlNameToJsChar #"\\" = "$BACKSLASH"
  | smlNameToJsChar #"~" = "$TILDE"
  | smlNameToJsChar #"`" = "$GRAVE"
  | smlNameToJsChar #"^" = "$HAT"
  | smlNameToJsChar #"|" = "$BAR"
  | smlNameToJsChar #"*" = "$ASTER"
  | smlNameToJsChar x = if Char.isAlphaNum x then String.str x else raise Fail "smlNameToJs: invalid character"
fun smlNameToJs name = String.translate smlNameToJsChar name
structure StringSet = RedBlackSetFn (struct open String; type ord_key = string end)
val JsReservedWords = StringSet.fromList
                          ["await", "break", "case", "catch", "class", "const", "continue", "debugger", "default", "delete", "do",
                           "else", "enum", "export", "extends", "false", "finally", "for", "function", "if", "import", "in",
                           "instanceof", "new", "null", "return", "super", "switch", "this", "throw", "true", "try", "typeof", "var",
                           "void", "while", "with", "yield",
                           (* disallowed in strict mode *)
                           "let", "static", "implements", "interface", "package", "private", "protected", "public"
                           (* forbidden in certain positions *)
                           (* "as", "async", "from", "get", "of", "set", "target" *)
                          ]
fun isIdentifierName name = case CharVectorSlice.getItem (CharVectorSlice.full name) of
                                NONE => false
                              | SOME (x0, xs) => (Char.isAlpha x0 orelse x0 = #"_" orelse x0 = #"$")
                                                 andalso CharVectorSlice.all (fn c => Char.isAlphaNum c orelse c = #"_" orelse c = #"$") xs
                                                 (* non-ASCII characters are not handled *)
fun isIdentifier name = isIdentifierName name andalso not (StringSet.member (JsReservedWords, name))
fun idToJs (JsSyntax.PredefinedId name) = name
  | idToJs (JsSyntax.UserDefinedId (TypedSyntax.MkVId (name, n))) = smlNameToJs name ^ "$" ^ Int.toString n (* the number must be non-negative *)

fun toStringLit (s : string) = "\"" ^ String.translate (fn #"\\" => "\\\\"
                                                       | #"\b" => "\\b" (* U+0008 *)
                                                       | #"\f" => "\\f" (* U+000C *)
                                                       | #"\n" => "\\n" (* U+000A *)
                                                       | #"\r" => "\\r" (* U+000D *)
                                                       | #"\t" => "\\t" (* U+0009 *)
                                                       | #"\v" => "\\v" (* U+000B *)
                                                       | #"\"" => "\\\""
                                                       | c => if Char.isAscii c andalso Char.isPrint c then
                                                                  String.str c
                                                              else
                                                                  let val x = Char.ord c
                                                                      val t = Int.fmt StringCvt.HEX x
                                                                  in if x < 0x10 then
                                                                         "\\x0" ^ t
                                                                     else
                                                                         "\\x" ^ t
                                                                  end
                                                       ) s ^ "\""
local fun doChar 0x5C = "\\\\"
        | doChar 0x08 = "\\b" (* U+0008 *)
        | doChar 0x0C = "\\f" (* U+000C *)
        | doChar 0x0A = "\\n" (* U+000A *)
        | doChar 0x0D = "\\r" (* U+000D *)
        | doChar 0x09 = "\\t" (* U+0009 *)
        | doChar 0x0B = "\\v" (* U+000B *)
        | doChar 0x22 = "\\\""
        | doChar i = if i < 0 orelse 0x10000 <= i then
                         raise Fail "this string cannot be expressed in JavaScript"
                     else if i < 128 andalso Char.isPrint (Char.chr i) then
                         String.str (Char.chr i)
                     else
                         let val t = Int.fmt StringCvt.HEX i
                         in if i < 0x10 then
                                "\\x0" ^ t
                            else if i < 0x100 then
                                "\\x" ^ t
                            else if i < 0x1000 then
                                "\\u0" ^ t
                            else
                                "\\u" ^ t
                         end
in
fun toWideStringLit (s : int vector) = "\"" ^ Vector.foldr (fn (x, acc) => doChar x ^ acc) "\"" s
end

(* precedence:
 * 18: Expression (comma; left-assoc)
 * 17: AssignmentExpression (= *= /= %= += -= <<= >>= >>>= &= ^= |=, right-assoc)
 * 16: ConditionalExpression
 * 15: LogicalORExpression (||; left-assoc)
 * 14: LogicalANDExpression (&&; left-assoc)
 * 13: BitwiseORExpression (|; left-assoc)
 * 12: BitwiseXORExpression (^; left-assoc)
 * 11: BitwiseANDExpression (&; left-assoc)
 * 10: EqualityExpression (== != === !==; left-assoc)
 * 9: RelationalExpression (< > <= >= instanceof in; left-assoc)
 * 8: ShiftExpression (<< >> >>>; left-assoc)
 * 7: AdditiveExpression ('+', '-'; left-assoc)
 * 6: MultiplicativeExpression ('*', '/', '%'; left-assoc)
 * 5: ExponentiationExpression ('**'; right-assoc)
 * 4: UnaryExpression
 * 3: PostfixExpression / UpdateExpression
 * 2: CallExpression (LeftHandSideExpression)
 * 1: MemberExpression
 * 0: PrimaryExpression: this | Identifier | Literal | ArrayLiteral | ObjectLiteral | FunctionExpression | '(' Expression ')'
 *)

structure Precedence = struct
val Expression = 18
val AssignmentExpression = 17
val ConditionalExpression = 16
val LogicalORExpression = 15
val UnaryExpression = 4
val CallExpression = 2
val MemberExpression = 1
val PrimaryExpression = 0
end

datatype Fragment = Fragment of string
                  | IncreaseIndent
                  | DecreaseIndent
                  | Indent
                  | LineTerminator
fun findNextFragment [] = NONE
  | findNextFragment (Fragment "" :: fragments) = findNextFragment fragments
  | findNextFragment (Fragment s :: _) = SOME s
  | findNextFragment (_ :: fragments) = findNextFragment fragments
fun processIndent (revAcc, indent, []) = List.rev revAcc
  | processIndent (revAcc, indent, Fragment s :: fragments) = processIndent (s :: revAcc, indent, fragments)
  | processIndent (revAcc, indent, IncreaseIndent :: fragments) = processIndent (revAcc, indent + 1, fragments)
  | processIndent (revAcc, indent, DecreaseIndent :: fragments) = processIndent (revAcc, indent - 1, fragments)
  | processIndent (revAcc, indent, Indent :: fragments) = processIndent (CharVector.tabulate (indent mod 8, fn _ => #" ") :: CharVector.tabulate (indent div 8, fn _ => #"\t") :: revAcc, indent, fragments)
  | processIndent (revAcc, indent, LineTerminator :: fragments) = processIndent ("\n" :: revAcc, indent, fragments)
fun buildProgram fragments = String.concat (processIndent ([], 0, fragments))

fun paren true exp rest = Fragment "(" :: exp (Fragment ")" :: rest)
  | paren false exp rest = exp rest

structure S = JsSyntax

fun intToString n = if n >= 0 then
                        Int.toString n
                    else
                        "-" ^ String.extract (Int.toString n, 1, NONE)

fun doKey (S.IntKey n) = toWideStringLit (JsSyntax.asciiStringAsIntVector (intToString n))
  | doKey (S.StringKey s) = if isIdentifier s then
                                s
                            else
                                toWideStringLit (JsSyntax.asciiStringAsIntVector s)
fun commaSep ([] : (Fragment list -> Fragment list) list) rest : Fragment list = rest
  | commaSep (x :: xs) rest = x (commaSep1 xs rest)
and commaSep1 [] rest = rest
  | commaSep1 (x :: xs) rest = Fragment ", " :: x (commaSep1 xs rest)
fun commaSepV (v : (Fragment list -> Fragment list ) vector) rest : Fragment list
    = (case VectorSlice.getItem (VectorSlice.full v) of
           NONE => rest
         | SOME (x, xs) => x (commaSepV1 xs rest)
      )
and commaSepV1 xs rest = (case VectorSlice.getItem xs of
                              NONE => rest
                            | SOME (x, xss) => Fragment ", " :: x (commaSepV1 xss rest)
                         )

datatype BinaryOp = InfixOp of (* prec *) int * string
                  | InfixOpR of (* prec *) int * string
                  | ExponentiationOp
fun binOpInfo S.PLUS = InfixOp (7, "+")
  | binOpInfo S.MINUS = InfixOp (7, "-")
  | binOpInfo S.TIMES = InfixOp (6, "*")
  | binOpInfo S.DIV = InfixOp (6, "/")
  | binOpInfo S.MOD = InfixOp (6, "%")
  | binOpInfo S.BITAND = InfixOp (11, "&")
  | binOpInfo S.BITXOR = InfixOp (12, "^")
  | binOpInfo S.BITOR = InfixOp (13, "|")
  | binOpInfo S.RSHIFT = InfixOp (8, ">>")
  | binOpInfo S.LSHIFT = InfixOp (8, "<<")
  | binOpInfo S.URSHIFT = InfixOp (8, ">>>")
  | binOpInfo S.LT = InfixOp (9, "<")
  | binOpInfo S.LE = InfixOp (9, "<=")
  | binOpInfo S.GT = InfixOp (9, ">")
  | binOpInfo S.GE = InfixOp (9, ">=")
  | binOpInfo S.EQUAL = InfixOp (10, "===")
  | binOpInfo S.NOTEQUAL = InfixOp (10, "!==")
  | binOpInfo S.LAXEQUAL = InfixOp (10, "==")
  | binOpInfo S.NOTLAXEQUAL = InfixOp (10, "!=")
  | binOpInfo S.AND = InfixOp (14, "&&")
  | binOpInfo S.OR = InfixOp (15, "||")
  | binOpInfo S.ASSIGN = InfixOp (17, "=")
  | binOpInfo S.INSTANCEOF = InfixOp (9, "instanceof")
  | binOpInfo S.IN = InfixOp (9, "in")
  | binOpInfo S.EXP = ExponentiationOp

fun doExp (prec, S.ConstExp ct) : Fragment list -> Fragment list
    = (fn rest => case ct of
                      S.Null => Fragment "null" :: rest
                    | S.False => Fragment "false" :: rest
                    | S.True => Fragment "true" :: rest
                    | S.Numeral s => Fragment s :: rest (* TODO: hexadecimal floating-point *)
                    | S.WideString s => Fragment (toWideStringLit s) :: rest
      )
  | doExp (prec, S.ThisExp) = (fn rest => Fragment "this" :: rest)
  | doExp (prec, S.VarExp id) = (fn rest => Fragment (idToJs id) :: rest)
  | doExp (prec, S.ObjectExp fields) = (fn rest => Fragment "{" :: commaSepV (Vector.map (fn (key, value) => fn rest => Fragment (doKey key) :: Fragment ": " :: doExp (Precedence.AssignmentExpression, value) rest) fields) (Fragment "}" :: rest))
  | doExp (prec, S.ArrayExp elements) = (fn rest => Fragment "[" :: doCommaSepExp elements (Fragment "]" :: rest))
  | doExp (prec, S.CallExp (fnExp, arguments)) = paren (prec < Precedence.CallExpression) (fn rest => doExp (Precedence.CallExpression, fnExp) (Fragment "(" :: doCommaSepExp arguments (Fragment ")" :: rest)))
  | doExp (prec, S.MethodExp (objectExp, methodName, arguments)) = paren (prec < Precedence.CallExpression) (fn rest => doExp (Precedence.MemberExpression, objectExp) (Fragment "." :: Fragment methodName :: Fragment "(" :: doCommaSepExp arguments (Fragment ")" :: rest)))
  | doExp (prec, S.NewExp (constructorExp, arguments)) = paren (prec < Precedence.MemberExpression) (fn rest => Fragment "new " :: doExp (Precedence.MemberExpression, constructorExp) (Fragment "(" :: doCommaSepExp arguments (Fragment ")" :: rest)))
  | doExp (prec, S.FunctionExp (parameters, body)) = (fn rest => Fragment "function" :: Fragment "(" :: commaSepV (Vector.map (fn id => fn rest => Fragment (idToJs id) :: rest) parameters) (Fragment ") {" :: IncreaseIndent :: LineTerminator :: doBlock body (DecreaseIndent :: Indent :: Fragment "}" :: rest)))
  | doExp (prec, S.BinExp (binOp, x, y)) = (case binOpInfo binOp of
                                                InfixOp (prec', symbol) => paren (prec < prec') (fn rest => doExp (prec', x) (Fragment " " :: Fragment symbol :: Fragment " " :: doExp (prec' - 1, y) rest))
                                              | InfixOpR (prec', symbol) => paren (prec < prec') (fn rest => doExp (prec' - 1, x) (Fragment " " :: Fragment symbol :: Fragment " " :: doExp (prec', y) rest))
                                              | ExponentiationOp => paren (prec < 5) (fn rest => doExp (3, x) (Fragment " ** " :: doExp (5, y) rest))
                                           )
  | doExp (prec, S.UnaryExp (unOp, x)) = let val symbol = case unOp of
                                                              S.VOID => "void"
                                                            | S.TYPEOF => "typeof"
                                                            | S.TONUMBER => "+"
                                                            | S.NEGATE => "-"
                                                            | S.BITNOT => "~"
                                                            | S.NOT => "!"
                                         in paren (prec < Precedence.UnaryExpression) (fn rest => Fragment symbol :: Fragment " " :: doExp (Precedence.UnaryExpression, x) rest)
                                         end
  | doExp (prec, S.IndexExp (objectExp, indexExp))
    = let val tryIdentifierName = case indexExp of
                                      S.ConstExp (S.WideString name) =>
                                      let val name = Vector.foldr (fn (c, NONE) => NONE
                                                                  | (c, SOME xs) => if c < 128 then
                                                                                        SOME (chr c :: xs)
                                                                                    else
                                                                                        NONE
                                                                  ) (SOME []) name
                                      in case name of
                                             SOME name => let val name = CharVector.fromList name
                                                          in if isIdentifierName name (* ES5 or later *) then
                                                                 SOME name
                                                             else
                                                                 NONE
                                                          end
                                           | NONE => NONE
                                      end
                                    | _ => NONE
          val indexPart = case tryIdentifierName of
                              SOME name => (fn rest => Fragment "." :: Fragment name :: rest)
                            | _ => (fn rest => Fragment "[" :: doExp (Precedence.Expression, indexExp) (Fragment "]" :: rest))
      in paren (prec < Precedence.MemberExpression) (doExp (Precedence.MemberExpression, objectExp) o indexPart)
      end
  | doExp (prec, S.CondExp (exp1, exp2, exp3)) = paren (prec < Precedence.ConditionalExpression) (fn rest => doExp (Precedence.LogicalORExpression, exp1) (Fragment " ? " :: doExp (Precedence.AssignmentExpression, exp2) (Fragment " : " :: doExp (Precedence.AssignmentExpression, exp3) rest)))
and doCommaSepExp elements = commaSepV (Vector.map (fn value => doExp (Precedence.AssignmentExpression, value)) elements)
and doStat (S.VarStat variables) = (fn rest => Indent :: Fragment "var " :: commaSepV (Vector.map (fn (id, NONE) => (fn rest => Fragment (idToJs (S.UserDefinedId id)) :: rest)
                                                                                                  | (id, SOME init) => (fn rest => Fragment (idToJs (S.UserDefinedId id)) :: Fragment " = " :: doExp (Precedence.AssignmentExpression, init) rest)
                                                                                                  ) variables) (Fragment ";" :: LineTerminator :: rest))
  | doStat (S.ExpStat exp) = (fn rest => let val rest' = Fragment ";" :: LineTerminator :: rest
                                             val fragments = doExp (Precedence.Expression, exp) rest'
                                             val needParen = case fragments of
                                                                 Fragment "{" :: _ => true
                                                               | Fragment "function" :: _ => true
                                                               | _ => false
                                         in Indent :: (if needParen then paren true (doExp (Precedence.Expression, exp)) rest' else fragments)
                                         end)
  | doStat (S.IfStat (cond, thenBlock, elseBlock))
    = (fn rest => let fun processElseIfs (elseIfsRev, elseBlock) = if Vector.length elseBlock = 1 then
                                                                       case Vector.sub (elseBlock, 0) of
                                                                           S.IfStat (cond', thenBlock, elseBlock) => processElseIfs ((cond', thenBlock) :: elseIfsRev, elseBlock)
                                                                         | _ => (elseIfsRev, elseBlock)
                                                                   else
                                                                       (elseIfsRev, elseBlock)
                      val (elseIfsRev, elseBlock) = processElseIfs ([], elseBlock)
                      val elsePart = if Vector.length elseBlock = 0 then
                                         DecreaseIndent :: Indent :: Fragment "}" :: LineTerminator :: rest
                                     else
                                         DecreaseIndent :: Indent :: Fragment "} else {" :: IncreaseIndent :: LineTerminator :: doBlock elseBlock (DecreaseIndent :: Indent :: Fragment "}" :: LineTerminator :: rest)
                      val elseIfsAndElsePart = List.foldl (fn ((cond, elseIfBlock), acc) => DecreaseIndent :: Indent :: Fragment "} else if (" :: doExp (Precedence.Expression, cond) (Fragment ") {" :: IncreaseIndent :: LineTerminator :: doBlock elseIfBlock acc)) elsePart elseIfsRev
                  in Indent :: Fragment "if (" :: doExp (Precedence.Expression, cond) (Fragment ") {" :: IncreaseIndent :: LineTerminator :: doBlock thenBlock elseIfsAndElsePart)
                  end
      )
  | doStat (S.ReturnStat NONE) = (fn rest => Indent :: Fragment "return;" :: LineTerminator :: rest)
  | doStat (S.ReturnStat (SOME exp)) = (fn rest => Indent :: Fragment "return " :: doExp (Precedence.Expression, exp) (Fragment ";" :: LineTerminator :: rest))
  | doStat (S.TryCatchStat (body, exnName, catch)) = (fn rest => Indent :: Fragment "try {" :: IncreaseIndent :: LineTerminator :: doBlock body (DecreaseIndent :: Indent :: Fragment "} catch (" :: Fragment (idToJs (S.UserDefinedId exnName)) :: Fragment ") {" :: IncreaseIndent :: LineTerminator :: doBlock catch (DecreaseIndent :: Indent :: Fragment "}" :: LineTerminator :: rest)))
  | doStat (S.ThrowStat exp) = (fn rest => Indent :: Fragment "throw " :: doExp (Precedence.Expression, exp) (Fragment ";" :: LineTerminator :: rest))
and doBlock stats = (fn rest => Vector.foldr (fn (stat, acc) => doStat stat acc) rest stats)

fun doProgram stats = buildProgram (doBlock stats [])
end;
