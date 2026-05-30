# Sequence Diagrams

- <https://mermaid.ai/blog/posts/sequence-diagrams-the-good-thing-uml-brought-to-software-development>
- <https://jessems.com/posts/2023-07-22-the-unreasonable-effectiveness-of-sequence-diagrams-in-mermaidjs/>
- <https://marketplace.visualstudio.com/items?itemName=bierner.markdown-mermaid&ssr=false#overview>
- <https://code.visualstudio.com/updates/v1_121#_mermaid-diagrams-in-markdown-preview-and-notebooks>
  - Mermaid new supported markdown preview language in VS Code 1.121!!! No more plugins required

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

```mermaid
sequenceDiagram
autonumber

participant ctl 
participant disp
participant cam
 

%% --- WHITE ---
note right of ctl: Show and Measure Patterns
loop white, red, green, blue
  ctl->>+disp: draw_frame(pattern_<color>)
  critical ShowTime
    disp->>-disp: 300 seconds
  end
  ctl->>+cam: measure_xyz
  critical 90 s
    cam->>-cam: measuring
  end
cam->>ctl: measurement_data_pattern_<color>
end
```
