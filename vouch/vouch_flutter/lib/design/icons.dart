import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Every icon in the app, by meaning (iconography DR3: one concept, one
/// glyph, everywhere). All Lucide, all outlined (DR5).
abstract final class VIcons {
  // Navigation.
  static const IconData home = LucideIcons.house;
  static const IconData approvals = LucideIcons.badgeCheck;
  static const IconData rules = LucideIcons.scrollText;
  static const IconData activity = LucideIcons.activity;
  static const IconData alexa = LucideIcons.audioLines;
  static const IconData members = LucideIcons.usersRound;

  // Identity & trust.
  static const IconData privacy = LucideIcons.shieldCheck;
  static const IconData voice = LucideIcons.audioWaveform;
  static const IconData mic = LucideIcons.mic;
  static const IconData person = LucideIcons.userRound;
  static const IconData recognised = LucideIcons.userCheck;
  static const IconData unrecognised = LucideIcons.userX;
  static const IconData hub = LucideIcons.radio;
  static const IconData lock = LucideIcons.lock;
  static const IconData fingerprint = LucideIcons.fingerprint;

  // Outcomes.
  static const IconData ok = LucideIcons.circleCheck;
  static const IconData fail = LucideIcons.circleX;
  static const IconData pending = LucideIcons.hourglass;
  static const IconData denied = LucideIcons.ban;
  static const IconData warn = LucideIcons.circleAlert;
  static const IconData clock = LucideIcons.clock;
  static const IconData timer = LucideIcons.timer;

  // Actions.
  static const IconData check = LucideIcons.check;
  static const IconData close = LucideIcons.x;
  static const IconData send = LucideIcons.arrowUp;
  static const IconData signOut = LucideIcons.logOut;
  static const IconData expand = LucideIcons.chevronDown;
  static const IconData arrowRight = LucideIcons.arrowRight;
  static const IconData filter = LucideIcons.listFilter;
  static const IconData terminal = LucideIcons.terminal;
  static const IconData compile = LucideIcons.scale;
  static const IconData disable = LucideIcons.circleSlash;
  static const IconData inbox = LucideIcons.inbox;
  static const IconData link = LucideIcons.link;
  static const IconData retry = LucideIcons.rotateCw;
  static const IconData copy = LucideIcons.copy;
}
