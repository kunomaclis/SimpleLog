# SimpleLog

SimpleLog is a combat and message log parser for Ashita v4. It provides a
compact, configurable alternative to the default battle log while preserving
the information needed to follow combat.

This maintained fork is developed by
[Kunomaclis](https://github.com/kunomaclis/SimpleLog). It is intended to remain
useful across Ashita-compatible Final Fantasy XI environments rather than being
tied to one server.

## Features

- Customizable combat messages and colors
- Target and damage condensation
- Message filtering by actor, target, and event type
- Crafting result previews
- In-game configuration through `/slog`
- Profile compatibility checks with readable fallback warnings
- Defensive packet handling during zoning and incomplete entity state

## Commands

- `/simplelog` or `/slog` opens the configuration menu.

## Maintained fork improvements

- Preserves combat packets when SimpleLog cannot safely resolve player or
  entity state.
- Suppresses duplicate output without hiding weapon skill damage, spell
  messages, job ability messages, or combat animations.
- Tracks relevant claimed and unclaimed combat actors, including actions
  involving party and alliance pets.
- Supports existing flat filter profiles and explicit target-specific filter
  settings without silently rewriting user profiles.

## Project lineage and credits

- Battlemod was created by Byrth.
- The Ashita port was created by Spiken.
- Action message parsing includes work by Farmboy0.
- Resource files were created with ResourceExtractor from the Windower Team.
- Continued maintenance, hardening, profile behavior, and UI work in this fork
  are directed and tested by Kunomaclis.
- Thanks to the Ashita development community and previous SimpleLog
  contributors.

## AI-assisted development disclosure

AI-assisted tools have been used for investigation, implementation support,
and code review in this fork. Kunomaclis directs the design, reviews the
changes, and performs the in-game validation. Project decisions and
maintenance responsibility remain with the maintainer.


