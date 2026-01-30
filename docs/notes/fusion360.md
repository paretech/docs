# Fusion 360

## Resources

- [Getting started with Fusion 360 (fishing reel video series)](https://www.youtube.com/playlist?list=PLmA_xUT-8UlJYjo3X_xUAR057IfpvvbkB)
  - Nice simple series from Autodesk. Really starts in part 3.
- [Autodesk Fusion 360 Glossary](https://productdesignonline.com/tips-and-tricks/autodesk-fusion-360-glossary/)
- ["Intent-Driven Design" workflow](https://www.autodesk.com/products/fusion-360/blog/intent-driven-design/)

## Glossary

- Chamfer:
- fillet (rounded-fill): Places an arc of a specified radius at the intersection of two lines or arcs. Often used to "round off" edges.
- Features appear on timeline
- Chamfer (beveled-cut)
- dogbone (overcut): A type of relief cut, see also "mouse-ear". Use when a rectangular part must seat fully. Two popular varieties: corner-centered (harsh) and edge-tangent (softer).
- diamond relief (a 45° “square”)
- "elephant-foot": bottom layers spreading under the weight of upper layers. Often mitigated by reducing print bed temperature.

## Tips

- Always create a new component
  - End of 2025, Fusion has started the switch to a new ["Intent-Driven Design" workflow](https://www.autodesk.com/products/fusion-360/blog/intent-driven-design/). This likely changes how components are created and likely differs from many instructional resources you may find.
- Sketches are not complete until they are dimensionally constrained (lock icon).
- Always keep sketches as simple as possible. Do not add fillets to the sketch, add later as features.
- Always prefer single dimension to two by using constraints.

## Questions

- What does project do?

## Modeling Symmetric Parts

There are at least three common workflow. Each of these have there place depending on what you are trying to achieve.

1. Sketch half, finish sketch, extrude and mirror (or symmetric extrude).
   - Mirror handled as a timeline "feature"
   - Subsequent changes to sketch drive solid of both sides after saving sketch changes.
1. Sketch half, create->mirror, apply symmetry constraint prior to dimensioning
   - tedious and error prone because you have to apply to every pair of line segments
   - both sides update in tandem
1. Sketch half, create->mirror
   - copy and mirror, doesn't update
