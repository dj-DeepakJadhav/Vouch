import pytest

from vouch_hub.router import route


@pytest.mark.parametrize("text,tool,args", [
    ("Alexa, unlock the front door.", "unlock_front_door", {}),
    ("order the new PlayStation for 500 euros", "place_order",
     {"item": "new playstation", "amount": 500, "currency": "EUR"}),
    ("buy batteries for twenty five pounds", "place_order",
     {"item": "batteries", "amount": 25, "currency": "GBP"}),
    ("Alexa, what's the weather?", "get_weather", {}),
    ("play some jazz", "play_music", {}),
    ("add oat milk to the shopping list", "add_to_list", {"item": "oat milk"}),
    ("add eggs to my list", "add_to_list", {"item": "eggs"}),
    ("what's on my calendar", "read_calendar", {}),
    ("send a message to mum saying I'm late", "send_message", {"to": "mum", "text": "i m late"}),
])
def test_route(text, tool, args):
    t, a = route(text)
    assert t == tool
    assert a.pop("utterance") == text  # verbatim, as Alexa+ would pass it
    assert a == args


def test_unknown():
    with pytest.raises(ValueError):
        route("tell me a joke")
