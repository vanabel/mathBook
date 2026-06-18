"""
Wolfram Language lexer for mathBook: highlights built-in symbols.

Pygments' stock MathematicaLexer marks every identifier as Token.Name, so
Integrate/Sin look unstyled. Wolfram convention: system symbols start with an
uppercase letter; user symbols usually start lowercase.
"""

from pygments.lexers.algebra import MathematicaLexer
from pygments.token import Name, Operator


class WolframBookLexer(MathematicaLexer):
    name = "Wolfram Book"
    aliases = ["wolframb", "wlbook"]
    filenames = []

    tokens = {
        "root": [
            *MathematicaLexer.tokens["root"][:1],
            # Out[], Out[-2], Out[-n] — stock lexer leaves % as Token.Error (red box).
            (r"%(?:%|\d+)?", Operator),
            # Line-continuation backslash (stock lexer also marks this as Error).
            (r"\\", Operator),
            *MathematicaLexer.tokens["root"][1:4],
            # Built-in / system symbols (Sin, Integrate, D, Pi, …)
            (r"[A-Z][a-zA-Z0-9]*", Name.Builtin),
            *MathematicaLexer.tokens["root"][4:],
        ]
    }
