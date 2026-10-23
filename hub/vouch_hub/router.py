"""Simulated Alexa+ NLU: keyword router from text to (tool, args).
Alexa+ hands MCP servers TEXT, never audio — this stands in for that."""
import re

from .normalise import normalise

_CURRENCY = {"euro": "EUR", "euros": "EUR", "eur": "EUR", "€": "EUR", "pound": "GBP",
             "pounds": "GBP", "£": "GBP", "dollar": "USD", "dollars": "USD", "$": "USD"}


def route(text: str) -> tuple[str, dict]:
    n = normalise(text)
    args: dict = {}
    if "unlock" in n.split() or "open the front door" in n:
        tool = "unlock_front_door"
    elif re.search(r"\b(order|buy|purchase)\b", n):
        tool = "place_order"
        m = re.search(r"\b(?:order|buy|purchase)\s+(?:me\s+)?(.+?)(?:\s+for\s+(\d+(?:\s\d+)?)\s*(\w+)?)?$", n)
        item = m.group(1) if m else n
        item = re.sub(r"^(the|a|an|some)\s+", "", item)
        amount = None
        cur = "EUR"
        if m and m.group(2):
            amount = int(m.group(2).split()[0])
            cur = _CURRENCY.get(m.group(3) or "", "EUR")
        else:
            sym = re.search(r"([€£$])\s?(\d+)", text)
            if sym:
                amount, cur = int(sym.group(2)), _CURRENCY[sym.group(1)]
        args = {"item": item, "amount": amount if amount is not None else 0, "currency": cur}
    elif "weather" in n:
        tool = "get_weather"
    elif re.search(r"\bplay\b", n):
        tool = "play_music"
    elif m := re.search(r"\badd\s+(.+?)\s+to\s+(?:the|my)?\s*(?:shopping\s+)?list\b", n):
        tool, args = "add_to_list", {"item": m.group(1)}
    elif "calendar" in n or "schedule" in n:
        tool = "read_calendar"
    elif m := re.search(r"\b(?:send|text|message)\s+(?:a\s+)?(?:message\s+)?(?:to\s+)?(\w+)\s+(?:saying|that)?\s*(.*)$", n):
        tool, args = "send_message", {"to": m.group(1), "text": m.group(2) or n}
    else:
        raise ValueError(f"no tool matches: {text!r}")
    args["utterance"] = text
    return tool, args
