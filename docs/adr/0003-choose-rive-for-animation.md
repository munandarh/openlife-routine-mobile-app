# ADR-0003: Use Rive for Animation with Static Fallback

**Date:** 2026-07-02
**Status:** Accepted

## Context

OpenLife Routine needs illustrations and animations for onboarding, empty states, and completion celebrations (per PRD §11). Two approaches were considered:

1. **Rive** — interactive vector animations with state machines.
2. **Lottie** — Adobe After Effects-based animations.

## Decision

We chose **Rive** with a **static PNG fallback** system.

- All illustrations are first authored as PNG vector art and bundled in `assets/vector/`.
- An `OpenLifeRiveView` widget renders PNGs now and will render `.riv` files when available.
- The `OpenLifeRiveView.illustration()` factory loads `Image.asset` with an `errorBuilder` → icon fallback.

## Rationale

- **Portfolio value**: Rive is less common than Lottie and demonstrates broader Flutter animation skills.
- **State machines**: Rive state machines allow interactive animations that respond to app state.
- **No Rive files yet**: While `.riv` files are not produced, the architecture is fully in place. The PNG fallback ensures the app looks polished from day one.

## Consequences

- **Positive**: Architecture ready for Rive; illustrations are already in use.
- **Negative**: Rive has a learning curve for designers; `.riv` files require specialized tools.
- **Neutral**: The PNG fallback adds ~22 MB to the APK; Rive files would reduce this.

## References

- [Rive documentation](https://rive.app/)
- [PRD §11 — Rive Animation Plan](../PRD.md)
- [Animation Guidelines](../../document-openlife/animation-guidelines.md)
