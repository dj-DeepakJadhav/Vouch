from utterance_attest.normalise import normalise, transcript_hash


def test_vectors(normalise_vectors):
    for case in normalise_vectors:
        got = normalise(case["input"])
        assert got == case["normalised"], case["input"]
        assert transcript_hash(got) == case["hash"], case["input"]


def test_wake_word_only_stripped_when_recognised():
    assert normalise("Hey pay Bob") == "hey pay bob"
    assert normalise("Alexa pay Bob") == "pay bob"


def test_number_word_collapsing_hundred_scale():
    assert normalise("send two hundred dollars") == "send 200 dollars"


def test_punctuation_and_whitespace_collapse():
    assert normalise("  send   10,   dollars!! ") == "send 10 dollars"
