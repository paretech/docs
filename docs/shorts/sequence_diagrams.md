# Sequence Diagrams

## Demo

```mermaid
sequenceDiagram
autonumber

participant ctl 
participant disp
participant cam
 

note right of ctl: Repeat for each pattern
loop ShowMeasure(W,R,G,B)
  ctl->>+disp: draw_frame(pattern_<color>)
  note over ctl,disp: hold_time=300s
  ctl->>+cam: measure_xyz(auto_exp_init=True)
  critical 90 s
    cam->>-cam: snap(count)
  end
  note right of cam: ~90s for 3x
cam->>ctl: measurement_data
end
```

## Resources

- <https://mermaid.ai/open-source/syntax/sequenceDiagram.html>
  - Syntax reference
- <https://mermaid.ai/blog/posts/sequence-diagrams-the-good-thing-uml-brought-to-software-development>
- <https://jessems.com/posts/2023-07-22-the-unreasonable-effectiveness-of-sequence-diagrams-in-mermaidjs/>
  - inspiration
- <https://marketplace.visualstudio.com/items?itemName=bierner.markdown-mermaid&ssr=false#overview>
  - VS Code plugin (for VS Code <1.121)
- <https://code.visualstudio.com/updates/v1_121#_mermaid-diagrams-in-markdown-preview-and-notebooks>
  - Mermaid new supported markdown preview language in VS Code 1.121!!! No more plugins required
