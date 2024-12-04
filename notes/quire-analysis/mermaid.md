Diagramming quire relations with mermaid?


h = "<img class=\"citeImage\" alt=\"image\"  src=\"http://www.homermultitext.org/iipsrv?IIIF=/project/homer/pyramidal/deepzoom/citebne/complutensian/v1/v1p19.tif/full/100,/0/default.jpg\" />"

## Ternion

```mermaid
graph TD

A[<img class="citeImage" alt="image"  src="https://manuscriptroadtrip.wordpress.com/wp-content/uploads/2015/01/voynich-detail.jpg" />] --> B
```


```mermaid
graph TD


Bifolio1[1] --> A1
Bifolio1 --> Bifolio2[2]
Bifolio1 --> A6

Bifolio2 --> A2
Bifolio2 --> Bifolio3[3]
Bifolio2 --> A5


Bifolio3 --> A3
Bifolio3 --> A4

```


graph TD
    style A fill:#ffffff,stroke:#000000,stroke-width:2
    style B fill:#ffffff,stroke:#000000,stroke-width:2
    style C fill:#ffffff,stroke:#000000,stroke-width:2
    
    A(( )) --> B(( ))
    B(( )) --> C(( ))