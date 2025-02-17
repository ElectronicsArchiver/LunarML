# SML Basis Library

## Top-level

```sml
infix  7  * / div mod
infix  6  + - ^
infixr 5  :: @
infix  4  = <> > >= < <=
infix  3  := o
infix  0  before

type unit = {}
eqtype int  (* primitive *)
eqtype word  (* primitive *)
type real  (* primitive *)
eqtype char  (* primitive *)
eqtype string  (* primitive *)
type substring = Substring.substring
type exn  (* primitive *)
eqtype 'a array  (* primitive *)
eqtype 'a vector  (* primitive *)
datatype 'a ref = ref of 'a  (* primitive *)
datatype bool = false | true
datatype option = datatype Option.option
datatype order = datatype General.order
datatype 'a list = nil | :: of 'a * 'a list

exception Bind = General.Bind
exception Chr = General.Chr
exception Div = General.Div
exception Domain = General.Domain
exception Fail = General.Fail
exception Match = General.Match
exception Overflow = General.Overflow
exception Size = General.Size
exception Span = General.Span
exception Subscript = General.Subscript
exception Empty = List.Empty
exception Option = Option.Option

val = : ''a * ''a -> bool
val <> : ''a * ''a -> bool
val abs : ∀'a:realint. 'a -> 'a  (* overloaded *)
val ~ : ∀'a:num. 'a -> 'a  (* overloaded *)
val + : ∀'a:num. 'a * 'a -> 'a  (* overloaded *)
val - : ∀'a:num. 'a * 'a -> 'a  (* overloaded *)
val * : ∀'a:num. 'a * 'a -> 'a  (* overloaded *)
val / : ∀'a:Real. 'a * 'a -> 'a  (* overloaded *)
val div : ∀'a:wordint. 'a * 'a -> 'a  (* overloaded *)
val mod : ∀'a:wordint. 'a * 'a -> 'a  (* overloaded *)
val < : ∀'a:numtxt. 'a * 'a -> bool  (* overloaded *)
val <= : ∀'a:numtxt. 'a * 'a -> bool  (* overloaded *)
val > : ∀'a:numtxt. 'a * 'a -> bool  (* overloaded *)
val >= : ∀'a:numtxt. 'a * 'a -> bool  (* overloaded *)

val ! : 'a ref -> 'a = General.!
val := : 'a ref * 'a -> unit = General.:=
val @ : ('a list * 'a list) -> 'a list = List.@
val ^ : string * string -> string = String.^
val app : ('a -> unit) -> 'a list -> unit = List.app
val before : 'a * unit -> 'a = General.before
val ceil : real -> int = Real.ceil
val chr : int -> char = Char.chr
val concat : string list -> string = String.concat
(* val exnMessage : not implemented yet *)
val exnName : exn -> string = General.exnName
val explode : string -> char list = String.explode
val floor : real -> int = Real.floor
val foldl : ('a * 'b -> 'b) -> 'b -> 'a list -> 'b = List.foldl
val foldr : ('a * 'b -> 'b) -> 'b -> 'a list -> 'b = List.foldr
val getOpt : 'a option * 'a -> 'a = Option.getOpt
val hd : 'a list -> 'a = List.hd
val ignore : 'a -> unit = General.ignore
val implode : char list -> string = String.implode
val isSome : 'a option -> bool = Option.isSome
val length : 'a list -> int = List.length
val map : ('a -> 'b) -> 'a list -> 'b list = List.map
val not : bool -> bool = Bool.not
val null : 'a list -> bool = List.null
val o : ('b -> 'c) * ('a -> 'b) -> 'a -> c = General.o
val ord : char -> int = Char.ord
val print : string -> unit = TextIO.print
val real : int -> real = Real.fromInt
(* val ref *)
val rev : 'a list -> 'a list = List.rev
val round : real -> int = Real.round
val size : string -> int = String.size
val str : char -> string = String.str
val substring : string * int * int -> string = String.substring
val tl : 'a list -> 'a list = List.tl
val trunc : real -> int = Real.trunc
(* val use : not supported *)
val valOf : 'a option -> 'a = Option.valOf
val vector : 'a list -> 'a vector = Vector.fromList;
```

## Signatures and structures

```sml
structure General : sig
  type unit = {}
  type exn = exn
  exception Bind
  exception Match
  exception Chr
  exception Div
  exception Domain
  exception Fail of string
  exception Overflow
  exception Size
  exception Span
  exception Subscript
  val exnName : exn -> string
  datatype order = LESS | EQUAL | GREATER
  val ! : 'a ref -> 'a
  val := : 'a ref * 'a -> unit
  val before : 'a * unit -> 'a
  val ignore : 'a -> unit
  val o : ('b -> 'c) * ('a -> 'b) -> 'a -> 'c
end

structure StringCvt :> sig
  datatype radix = BIN | OCT | DEC | HEX
  datatype realfmt = SCI of int option
                   | FIX of int option
                   | GEN of int option
                   | EXACT
  type ('a,'b) reader = 'b -> ('a * 'b) option
  val padLeft : char -> int -> string -> string
  val padRight : char -> int -> string -> string
  val splitl : (char -> bool) -> (char, 'a) reader -> 'a -> string * 'a
  val takel : (char -> bool) -> (char, 'a) reader -> 'a -> string
  val dropl : (char -> bool) -> (char, 'a) reader -> 'a -> 'a
  val skipWS : (char, 'a) reader -> 'a -> 'a
  type cs
  val scanString : ((char, cs) reader -> ('a, cs) reader) -> string -> 'a option
end

structure Bool : sig
  datatype bool = datatype bool
  val not : bool -> bool
  val toString : bool -> string
  val scan : (char, 'a) StringCvt.reader -> (bool, 'a) StringCvt.reader
  val fromString : string -> bool option
end

signature INTEGER = sig
  eqtype int
  val toLarge : int -> LargeInt.int
  val fromLarge : LargeInt.int -> int
  val toInt : int -> Int.int
  val fromInt : Int.int -> int
  val precision : Int.int option
  val minInt : int option
  val maxInt : int option
  val + : int * int -> int
  val - : int * int -> int
  val * : int * int -> int
  val div : int * int -> int
  val mod : int * int -> int
  val quot : int * int -> int
  val rem : int * int -> int
  val compare : int * int -> order
  val < : int * int -> bool
  val <= : int * int -> bool
  val > : int * int -> bool
  val >= : int * int -> bool
  val ~ : int -> int
  val abs : int -> int
  val min : int * int -> int
  val max : int * int -> int
  val sign : int -> Int.int
  val sameSign : int * int -> bool
  val fmt : StringCvt.radix -> int -> string
  val toString : int -> string
  val scan : StringCvt.radix -> (char, 'a) StringCvt.reader -> (int, 'a) StringCvt.reader
  val fromString : string -> int option
end

structure Int :> INTEGER where type int = int
structure IntInf :> sig
  include INTEGER
  val divMod : int * int -> int * int
  val quotRem : int * int -> int * int
  val pow : int * Int.int -> int
  val log2 : int -> Int.int
  val orb : int * int -> int
  val xorb : int * int -> int
  val andb : int * int -> int
  val notb : int -> int
  val << : int * Word.word -> int
  val ~>> : int * Word.word -> int
end
structure LargeInt : INTEGER = IntInf

signature WORD = sig
  eqtype word
  val wordSize : int
  val toLarge : word -> LargeWord.word
  val toLargeX : word -> LargeWord.word
  val toLargeWord : word -> LargeWord.word
  val toLargeWordX : word -> LargeWord.word
  val fromLarge : LargeWord.word -> word
  val fromLargeWord : LargeWord.word -> word
  val toLargeInt : word -> LargeInt.int
  val toLargeIntX : word -> LargeInt.int
  val fromLargeInt : LargeInt.int -> word
  val toInt : word -> int
  val toIntX : word -> int
  val fromInt : int -> word
  val andb : word * word -> word
  val orb : word * word -> word
  val xorb : word * word -> word
  val notb : word -> word
  val << : word * Word.word -> word
  val >> : word * Word.word -> word
  val ~>> : word * Word.word -> word
  val + : word * word -> word
  val - : word * word -> word
  val * : word * word -> word
  val div : word * word -> word
  val mod : word * word -> word
  val compare : word * word -> order
  val < : word * word -> bool
  val <= : word * word -> bool
  val > : word * word -> bool
  val >= : word * word -> bool
  val ~ : word -> word
  val min : word * word -> word
  val max : word * word -> word
  val fmt : StringCvt.radix -> word -> string
  val toString : word -> string
  val scan : StringCvt.radix -> (char, 'a) StringCvt.reader -> (word, 'a) StringCvt.reader
  val fromString : string -> word option
end

structure Word :> WORD where type word = word
structure Word8 :> WORD
structure Word16 :> WORD
structure Word32 :> WORD
structure Word64 :> WORD
structure LargeWord = Word64

structure IEEEReal : sig
  exception Unordered
  datatype real_order = LESS | EQUAL | GREATER | UNORDERED
  datatype float_class = NAN | INF | ZERO | NORMAL | SUBNORMAL
  datatype rounding_mode = TO_NEAREST | TO_NEGINF | TO_POSINF | TO_ZERO
  type decimal_approx = { class : float_class, sign : bool, digits : int list, exp : int }
end

signature REAL = sig
  type real
  (* structure Math *)
  (* val radix : int *)
  (* val precision : int *)
  val maxFinite : real
  val minPos : real
  val minNormalPos : real
  val posInf : real
  val negInf : real
  val + : real * real -> real
  val - : real * real -> real
  val * : real * real -> real
  val / : real * real -> real
  (* val rem : real * real -> real *)
  (* val *+ : real * real * real -> real *)
  (* val *- : real * real * real -> real *)
  val ~ : real -> real
  val abs : real -> real
  (* val min : real * real -> real *)
  (* val max : real * real -> real *)
  val sign : real -> int
  val signBit : real -> bool
  val sameSign : real * real -> bool
  val copySign : real * real -> real
  val compare : real * real -> order
  val compareReal : real * real -> IEEEReal.real_order
  val < : real * real -> bool
  val <= : real * real -> bool
  val > : real * real -> bool
  val >= : real * real -> bool
  val == : real * real -> bool
  val != : real * real -> bool
  val ?= : real * real -> bool
  val unordered : real * real -> bool
  val isFinite : real -> bool
  val isNan : real -> bool
  val isNormal : real -> bool
  val class : real -> IEEEReal.float_class
  (* val toManExp : real -> { man : real, exp : int } *)
  (* val fromManExp : { man : real, exp : int } -> real *)
  (* val split : real -> { whole : real, frac : real } *)
  (* val realMod : real -> real *)
  (* val nextAfter : real * real -> real *)
  val checkFloat : real -> real
  val realFloor : real -> real
  val realCeil : real -> real
  val realTrunc : real -> real
  val realRound : real -> real
  val floor : real -> int
  val ceil : real -> int
  val trunc : real -> int
  val round : real -> int
  val toInt : IEEEReal.rounding_mode -> real -> int
  (* val toLargeInt : IEEEReal.rounding_mode -> real -> LargeInt.int *)
  val fromInt : int -> real
  (* val fromLargeInt : LargeInt.int -> real *)
  (* val toLarge : real -> LargeReal.real *)
  (* val fromLarge : IEEEReal.rounding_mode -> LargeReal.real -> real *)
  val fmt : StringCvt.realfmt -> real -> string
  val toString : real -> string
  val scan : (char, 'a) StringCvt.reader -> (real, 'a) StringCvt.reader
  val fromString : string -> real option
  (* val toDecimal : real -> IEEEReal.decimal_approx *)
  (* val fromDecimal : IEEEReal.decimal_approx -> real option *)
end

structure Real : REAL where type real = real

structure Math : sig
  type real = real
  val pi : real
  val e : real
  val sqrt : real -> real
  val sin : real -> real
  val cos : real -> real
  val tan : real -> real
  val asin : real -> real
  val acos : real -> real
  val atan : real -> real
  val atan2 : real * real -> real
  val exp : real -> real
  val pow : real * real -> real
  val ln : real -> real
  val log10 : real -> real
  val sinh : real -> real
  val cosh : real -> real
  val tanh : real -> real
end

signature CHAR = sig
  eqtype char
  eqtype string
  val minChar : char
  val maxChar : char
  val maxOrd : int
  val ord : char -> int
  val chr : int -> char
  val succ : char -> char
  val pred : char -> char
  val compare : char * char -> order
  val < : char * char -> bool
  val <= : char * char -> bool
  val > : char * char -> bool
  val >= : char * char -> bool
  val contains : string -> char -> bool
  val notContains : string -> char -> bool
  val isAscii : char -> bool
  val toLower : char -> char
  val toUpper : char -> char
  val isAlpha : char -> bool
  val isAlphaNum : char -> bool
  val isCntrl : char -> bool
  val isDigit : char -> bool
  val isGraph : char -> bool
  val isHexDigit : char -> bool
  val isLower : char -> bool
  val isPrint : char -> bool
  val isSpace : char -> bool
  val isPunct : char -> bool
  val isUpper : char -> bool
  val toString : char -> String.string
  val scan : (Char.char, 'a) StringCvt.reader -> (char, 'a) StringCvt.reader
  val fromString : String.string -> char option
  val toCString : char -> String.string
  (* val fromCString : String.string -> char option *)
end

structure Char :> CHAR where type char = char

signature STRING = sig
  eqtype string
  eqtype char
  val maxSize : int
  val size : string -> int
  val sub : string * int -> char
  val extract : string * int * int option -> string
  val substring : string * int * int -> string
  val ^ : string * string -> string
  val concat : string list -> string
  val concatWith : string -> string list -> string
  val str : char -> string
  val implode : char list -> string
  val explode : string -> char list
  val map : (char -> char) -> string -> string
  val translate : (char -> string) -> string -> string
  val tokens : (char -> bool) -> string -> string list
  val fields : (char -> bool) -> string -> string list
  val isPrefix : string -> string -> bool
  (* val isSubstring : string -> string -> bool *)
  val isSuffix : string -> string -> bool
  val compare : string * string -> order
  (* val collate : (char * char -> order) -> string * string -> order *)
  val < : string * string -> bool
  val <= : string * string -> bool
  val > : string * string -> bool
  val >= : string * string -> bool
  val toString : string -> string
  val scan : (Char.char, 'a) StringCvt.reader -> (string, 'a) StringCvt.reader
  val fromString : String.string -> string option
  val toCString : string -> String.string
  (* val fromCString : String.string -> string option *)

  (* https://github.com/SMLFamily/BasisLibrary/wiki/2015-003d-STRING *)
  val implodeRev : char list -> string
end

structure String :> STRING where type string = string

structure Substring :> sig
  type substring
  type char = char
  type string = string
  val sub : substring * int -> char
  val size : substring -> int
  val base : substring -> string * int * int
  val full : string -> substring
  val string : substring -> string
  val isEmpty : substring -> bool
  val getc : substring -> (char * substring) option
  val first : substring -> char option
  val triml : int -> substring -> substring
  val trimr : int -> substring -> substring
  val slice : substring * int * int option -> substring
  val concat : substring list -> string
  val concatWith : string -> substring list -> string
  val isPrefix : string -> substring -> bool
  val isSuffix : string -> substring -> bool
  val compare : substring * substring -> order
  val splitl : (char -> bool) -> substring -> substring * substring
  val splitr : (char -> bool) -> substring -> substring * substring
  val dropl : (char -> bool) -> substring -> substring
  val dropr : (char -> bool) -> substring -> substring
  val takel : (char -> bool) -> substring -> substring
  val taker : (char -> bool) -> substring -> substring
  val foldl : (char * 'a -> 'a) -> 'a -> substring -> 'a
  val foldr : (char * 'a -> 'a) -> 'a -> substring -> 'a
end

structure List : sig
  datatype list = datatype list
  exception Empty
  val null : 'a list -> bool
  val length : 'a list -> int
  val @ : 'a list * 'a list -> 'a list
  val hd : 'a list -> 'a
  val tl : 'a list -> 'a list
  val last : 'a list -> 'a
  val getItem : 'a list -> ('a * 'a list) option
  val nth : 'a list * int -> 'a
  val take : 'a list * int -> 'a list
  val drop : 'a list * int -> 'a list
  val rev : 'a list -> 'a list
  val concat : 'a list list -> 'a list
  val revAppend : 'a list * 'a list -> 'a list
  val app : ('a -> unit) -> 'a list -> unit
  val map : ('a -> 'b) -> 'a list -> 'b list
  val mapPartial : ('a -> 'b option) -> 'a list -> 'b list
  val find : ('a -> bool) -> 'a list -> 'a option
  val filter : ('a -> bool) -> 'a list -> 'a list
  val partition : ('a -> bool) -> 'a list -> 'a list * 'a list
  val foldl : ('a * 'b -> 'b) -> 'b -> 'a list -> 'b
  val foldr : ('a * 'b -> 'b) -> 'b -> 'a list -> 'b
  val exists : ('a -> bool) -> 'a list -> bool
  val all : ('a -> bool) -> 'a list -> bool
  val tabulate : int * (int -> 'a) -> 'a list
  val collate : ('a * 'a -> order) -> 'a list * 'a list -> order
end

structure ListPair : sig
  exception UnequalLengths
  val zip : 'a list * 'b list -> ('a * 'b) list
  val zipEq : 'a list * 'b list -> ('a * 'b) list
  val unzip : ('a * 'b) list -> 'a list * 'b list
  val app : ('a * 'b -> unit) -> 'a list * 'b list -> unit
  val appEq : ('a * 'b -> unit) -> 'a list * 'b list -> unit
  val map : ('a * 'b -> 'c) -> 'a list * 'b list -> 'c list
  val mapEq : ('a * 'b -> 'c) -> 'a list * 'b list -> 'c list
  val foldl : ('a * 'b * 'c -> 'c) -> 'c -> 'a list * 'b list -> 'c
  val foldr : ('a * 'b * 'c -> 'c) -> 'c -> 'a list * 'b list -> 'c
  val foldlEq : ('a * 'b * 'c -> 'c) -> 'c -> 'a list * 'b list -> 'c
  val foldrEq : ('a * 'b * 'c -> 'c) -> 'c -> 'a list * 'b list -> 'c
  val all : ('a * 'b -> bool) -> 'a list * 'b list -> bool
  val exists : ('a * 'b -> bool) -> 'a list * 'b list -> bool
  val allEq : ('a * 'b -> bool) -> 'a list * 'b list -> bool
end

structure Option : sig
  datatype 'a option = NONE | SOME of 'a
  exception Option
  val getOpt : 'a option * 'a -> 'a
  val isSome : 'a option -> bool
  val valOf : 'a option -> 'a
  val filter : ('a -> bool) -> 'a -> 'a option
  val join : 'a option option -> 'a option
  val app : ('a -> unit) -> 'a option -> unit
  val map : ('a -> 'b) -> 'a option -> 'b option
  val mapPartial : ('a -> 'b option) -> 'a option -> 'b option
  val compose : ('a -> 'b) * ('c -> 'a option) -> 'c -> 'b option
  val composePartial : ('a -> 'b option) * ('c -> 'a option) -> 'c -> 'b option
end

structure Vector : sig
  datatype vector = datatype vector
  val maxLen : int
  val fromList : 'a list -> 'a vector
  val tabulate : int * (int -> 'a) -> 'a vector
  val length : 'a vector -> int
  val sub : 'a vector * int -> 'a
  val update : 'a vector * int * 'a -> 'a vector
  val concat : 'a vector list -> 'a vector
  val appi : (int * 'a -> unit) -> 'a vector -> unit
  val app : ('a -> unit) -> 'a vector -> unit
  val mapi : (int * 'a -> 'b) -> 'a vector -> 'b vector
  val map : ('a -> 'b) -> 'a vector -> 'b vector
  val foldli : (int * 'a * 'b -> 'b) -> 'b -> 'a vector -> 'b
  val foldri : (int * 'a * 'b -> 'b) -> 'b -> 'a vector -> 'b
  val foldl : ('a * 'b -> 'b) -> 'b -> 'a vector -> 'b
  val foldr : ('a * 'b -> 'b) -> 'b -> 'a vector -> 'b
  val findi : (int * 'a -> bool) -> 'a vector -> (int * 'a) option
  val find : ('a -> bool) -> 'a vector -> 'a option
  val exists : ('a -> bool) -> 'a vector -> bool
  val all : ('a -> bool) -> 'a vector -> bool
  val collate : ('a * 'a -> order) -> 'a vector * 'a vector -> order
end

structure VectorSlice :> sig
  type 'a slice
  val length : 'a slice -> int
  val sub : 'a slice * int -> 'a
  val full : 'a Vector.vector -> 'a slice
  val slice : 'a Vector.vector * int * int option -> 'a slice
  val subslice : 'a slice * int * int option -> 'a slice
  val vector : 'a slice -> 'a Vector.vector
  val getItem : 'a slice -> ('a * 'a slice) option
  val exists : ('a -> bool) -> 'a slice -> bool
end

structure Array : sig
  datatype array = datatype array
  datatype vector = datatype vector
  val maxLen : int
  val array : int * 'a -> 'a array
  val fromList : 'a list -> 'a array
  val tabulate : int * (int -> 'a) -> 'a array
  val length : 'a array -> int
  val sub : 'a array * int -> 'a
  val update : 'a array * int * 'a -> unit
  val copyVec : { src : 'a vector, dst : 'a array, di : int } -> unit
  val appi : (int * 'a -> unit) -> 'a array -> unit
  val app : ('a -> unit) -> 'a array -> unit
  val modifyi : (int * 'a -> 'a) -> 'a array -> unit
  val modify : ('a -> 'a) -> 'a array -> unit
  val foldli : (int * 'a * 'b -> 'b) -> 'b -> 'a array -> 'b
  val foldri : (int * 'a * 'b -> 'b) -> 'b -> 'a array -> 'b
  val foldl : ('a * 'b -> 'b) -> 'b -> 'a array -> 'b
  val foldr : ('a * 'b -> 'b) -> 'b -> 'a array -> 'b
  val findi : (int * 'a -> bool) -> 'a array -> (int * 'a) option
  val find : ('a -> bool) -> 'a array -> 'a option
  val exists : ('a -> bool) -> 'a array -> bool
  val all : ('a -> bool) -> 'a array -> bool
  val collate : ('a * 'a -> order) -> 'a array * 'a array -> order
  val toList : 'a array -> 'a list
  val fromVector : 'a vector -> 'a array
  val toVector : 'a array -> 'a vector
end

structure ArraySlice :> sig
  type 'a slice
  val length : 'a slice -> int
  val sub : 'a slice * int -> 'a
  val update : 'a slice * int * 'a -> unit
  val full : 'a Array.array -> 'a slice
  val slice : 'a Array.array * int * int option -> 'a slice
  val subslice : 'a slice * int * int option -> 'a slice
  val vector : 'a slice -> 'a Vector.vector
  val copy : { src : 'a slice, dst : 'a Array.array, di : int } -> unit
  val copyVec : { src : 'a VectorSlice.slice, dst : 'a Array.array, di : int } -> unit
  val isEmpty : 'a slice -> bool
  val getItem : 'a slice -> ('a * 'a slice) option
  val appi : (int * 'a -> unit) -> 'a slice -> unit
  val app : ('a -> unit) -> 'a slice -> unit
  val modifyi : (int * 'a -> 'a) -> 'a slice -> unit
  val modify : ('a -> 'a) -> 'a slice -> unit
  val foldli : (int * 'a * 'b -> 'b) -> 'b -> 'a slice -> 'b
  val foldri : (int * 'a * 'b -> 'b) -> 'b -> 'a slice -> 'b
  val foldl : ('a * 'b -> 'b) -> 'b -> 'a slice -> 'b
  val foldr : ('a * 'b -> 'b) -> 'b -> 'a slice -> 'b
  val findi : (int * 'a -> bool) -> 'a slice -> (int * 'a) option
  val find : ('a -> bool) -> 'a slice -> 'a option
  val exists : ('a -> bool) -> 'a slice -> bool
  val all : ('a -> bool) -> 'a slice -> bool
  val collate : ('a * 'a -> order) -> 'a slice * 'a slice -> order
end

signature MONO_VECTOR = sig
  type vector
  type elem
  val maxLen
  val fromList : elem list -> vector
  val tabulate : int * (int -> elem) -> vector
  val length : vector -> int
  val sub : vector * int -> elem
  val update : vector * int * elem -> vector
  val concat : vector list -> vector
  val appi : (int * elem -> unit) -> vector -> unit
  val app : (elem -> unit) -> vector -> unit
  val mapi : (int * elem -> elem) -> vector -> vector
  val map : (elem -> elem) -> vector -> vector
  val foldli : (int * elem * 'a -> 'a) -> 'a -> vector -> 'a
  val foldri : (int * elem * 'a -> 'a) -> 'a -> vector -> 'a
  val foldl : (elem * 'a -> 'a) -> 'a -> vector -> 'a
  val foldr : (elem * 'a -> 'a) -> 'a -> vector -> 'a
  val findi : (int * elem -> bool) -> vector -> (int * elem) option
  val find : (elem -> bool) -> vector -> elem option
  val exists : (elem -> bool) -> vector -> bool
  val all : (elem -> bool) -> vector -> bool
  val collate : (elem * elem -> order) -> vector * vector -> order

  (* https://github.com/SMLFamily/BasisLibrary/wiki/2015-003f-MONO_VECTOR *)
  val toList : vector -> elem list
  val append : vector * elem -> vector
  val prepend : elem * vector -> vector
end

structure CharVector :> MONO_VECTOR where type vector = String.string
                                    where type elem = char
structure Word8Vector :> MONO_VECTOR where type elem = Word8.word

signature MONO_VECTOR_SLICE = sig
  type elem
  type vector
  type slice
  val length : slice -> int
  val sub : slice * int -> elem
  val full : vector -> slice
  val slice : vector * int * int option -> slice
  val subslice : slice * int * int option -> slice
  val base : slice -> vector * int * int
  val vector : slice -> vector
  val concat : slice list -> vector
  val isEmpty : slice -> bool
  val getItem : slice -> (elem * slice) option
  val appi : (int * elem -> unit) -> slice -> unit
  val app : (elem -> unit) -> slice -> unit
  val mapi : (int * elem -> elem) -> slice -> vector
  val map : (elem -> elem) -> slice -> vector
  val foldli : (int * elem * 'b -> 'b) -> 'b -> slice -> 'b
  val foldri : (int * elem * 'b -> 'b) -> 'b -> slice -> 'b
  val foldl : (elem * 'b -> 'b) -> 'b -> slice -> 'b
  val foldr : (elem * 'b -> 'b) -> 'b -> slice -> 'b
  val findi : (int * elem -> bool) -> slice -> (int * elem) option
  val find : (elem -> bool) -> slice -> elem option
  val exists : (elem -> bool) -> slice -> bool
  val all : (elem -> bool) -> slice -> bool
  val collate : (elem * elem -> order) -> slice * slice -> order
end

structure CharVectorSlice :> MONO_VECTOR_SLICE where type vector = CharVector.vector
                                               where type elem = char
                                               where type slice = Substring.substring
structure Word8VectorSlice :> MONO_VECTOR_SLICE where type vector = Word8Vector.vector
                                                where type elem = Word8.word

signature MONO_ARRAY = sig
  eqtype array
  type elem
  type vector
  val maxLen : int
  val array : int * elem -> array
  val fromList : elem list -> array
  val tabulate : int * (int -> elem) -> array
  val length : array -> int
  val sub : array * int -> elem
  val update : array * int * elem -> unit
  val vector : array -> vector
  val copy : { src : array, dst : array, di : int } -> unit
  val copyVec : { src : vector, dst : array, di : int } -> unit
  val appi : (int * elem -> unit) -> array -> unit
  val app : (elem -> unit) -> array -> unit
  val modifyi : (int * elem -> elem) -> array -> unit
  val modify : (elem -> elem) -> array -> unit
  val foldli : (int * elem * 'b -> 'b) -> 'b -> array -> 'b
  val foldri : (int * elem * 'b -> 'b) -> 'b -> array -> 'b
  val foldl : (elem * 'b -> 'b) -> 'b -> array -> 'b
  val foldr : (elem * 'b -> 'b) -> 'b -> array -> 'b
  val findi : (int * elem -> bool) -> array -> (int * elem) option
  val find : (elem -> bool) -> array -> elem option
  val exists : (elem -> bool) -> array -> bool
  val all : (elem -> bool) -> array -> bool
  val collate : (elem * elem -> order) -> array * array -> order

  (* https://github.com/SMLFamily/BasisLibrary/wiki/2015-003h-MONO_ARRAY *)
  val toList : array -> elem list
  val fromVector : vector -> array
  val toVector : array -> vector (* = vector *)
end

structure CharArray : MONO_ARRAY where type vector = CharVector.vector
                                 where type elem = char
structure Word8Array : MONO_ARRAY where type vector = Word8Vector.vector
                                  where type elem = Word8.word

signature MONO_ARRAY_SLICE = sig
  type elem
  type array
  type slice
  type vector
  type vector_slice
  val length : slice -> int
  val sub : slice * int -> elem
  val update : slice * int * elem -> unit
  val full : array -> slice
  val slice : array * int * int option -> slice
  val subslice : slice * int * int option -> slice
  val base : slice -> array * int * int
  val vector : slice -> vector
  val copy : { src : slice, dst : array, di : int } -> unit
  val copyVec : { src : vector_slice, dst : array, di : int } -> unit
  val isEmpty : slice -> bool
  val getItem : slice -> (elem * slice) option
  val appi : (int * elem -> unit) -> slice -> unit
  val app : (elem -> unit) -> slice -> unit
  val modifyi : (int * elem -> elem) -> slice -> unit
  val modify : (elem -> elem) -> slice -> unit
  val foldli : (int * elem * 'b -> 'b) -> 'b -> slice -> 'b
  val foldri : (int * elem * 'b -> 'b) -> 'b -> slice -> 'b
  val foldl : (elem * 'b -> 'b) -> 'b -> slice -> 'b
  val foldr : (elem * 'b -> 'b) -> 'b -> slice -> 'b
  val findi : (int * elem -> bool) -> slice -> (int * elem) option
  val find : (elem -> bool) -> slice -> elem option
  val exists : (elem -> bool) -> slice -> bool
  val all : (elem -> bool) -> slice -> bool
  val collate : (elem * elem -> order) -> slice * slice -> order
end

structure CharArraySlice : MONO_ARRAY_SLICE where type vector = CharVector.vector
                                            where type vector_slice = CharVectorSlice.slice
                                            where type array = CharArray.array
                                            where type elem = char
structure Word8ArraySlice : MONO_ARRAY_SLICE where type vector = Word8Vector.vector
                                             where type vector_slice = Word8VectorSlice.slice
                                             where type array = Word8Array.array
                                             where type elem = Word8

signature BYTE = sig
  val byteToChar : Word8.word -> char
  val charToByte : char -> Word8.word
  val bytesToString : Word8Vector.vector -> string
  val stringToBytes : string -> Word8Vector.vector
end

structure Byte :> BYTE

structure IO : sig
  exception Io of { name : string
                  , function : string
                  , cause : exn
                  }
end

structure TextIO : sig
  type instream
  type outstream
  type vector = string
  type elem = char
  val input : instream -> vector
  val input1 : instream -> elem option
  val inputN : instream * int -> vector
  val inputAll : instream -> vector
  val closeIn : instream -> unit
  val endOfStream : instream -> bool
  val output : outstream * vector -> unit
  val output1 : outstream * elem -> unit
  val flushOut : outstream -> unit
  val closeOut : outstream -> unit
  val inputLine : instream -> string option
  val openIn : string -> instream
  val openOut : string -> outstream
  val openAppend : string -> outstream
  val stdIn : instream
  val stdOut : outstream
  val stdErr : outstream
  val print : string -> unit
end

structure OS : sig
  structure FileSys : sig
    val chDir : string -> unit (* requires LuaFileSystem *)
    val getDir : unit -> string (* requires LuaFileSystem *)
    val mkDir : string -> unit (* requires LuaFileSystem *)
    val rmDir : string -> unit (* requires LuaFileSystem *)
    val isDir : string -> bool (* requires LuaFileSystem *)
    val isLink : string -> bool (* requires LuaFileSystem *)
    val readLink : string -> string (* requires LuaFileSystem 1.7.0 or later *)
    val remove : string -> unit
    val rename : { old : string, new : string } -> unit
  end
  structure IO : sig
  end
  structure Path : sig
    (* currently Unix-style only *)
    exception Path
    exception InvalidArc
    val parentArc : string
    val currentArc : string
    val fromString : string -> { isAbs : bool, vol : string, arcs : string list }
    val toString : { isAbs : bool, vol : string, arcs : string list } -> string
    val splitDirFile : string -> { dir : string, file : string }
    val joinDirFile : { dir : string, file : string } -> string
    val dir : string -> string
    val file : string -> string
    val splitBaseExt : string -> { base : string, ext : string option }
    val joinBaseExt : { base : string, ext : string option } -> string
    val base : string -> string
    val ext : string -> string option
    val mkCanonical : string -> string
    val mkAbsolute : { path : string, relativeTo : string } -> string
    val mkRelative : { path : string, relativeTo : string } -> string
    val isAbsolute : string -> bool
    val isRelative : string -> bool
    val concat : string * string -> string
  end
  structure Process : sig
    type status
    val success : status
    val failure : status
    val isSuccess : status -> bool
    val system : string -> status
    val exit : status -> 'a
    val terminate : status -> 'a
    val getEnv : string -> string option
  end
  eqtype syserror
  exception SysErr of string * syserror option
end

structure CommandLine : sig
  val name : unit -> string
  val arguments : unit -> string list
end
```
