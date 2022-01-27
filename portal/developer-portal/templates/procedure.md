[//]: # ((C) Copyright 2021 Hewlett Packard Enterprise Development LP)

[//]: # (Permission is hereby granted, free of charge, to any person obtaining a)
[//]: # (copy of this software and associated documentation files (the "Software"),)
[//]: # (to deal in the Software without restriction, including without limitation)
[//]: # (the rights to use, copy, modify, merge, publish, distribute, sublicense,)
[//]: # (and/or sell copies of the Software, and to permit persons to whom the)
[//]: # (Software is furnished to do so, subject to the following conditions:)

[//]: # (The above copyright notice and this permission notice shall be included)
[//]: # (in all copies or substantial portions of the Software.)

[//]: # (THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR)
[//]: # (IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,)
[//]: # (FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL)
[//]: # (THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR)
[//]: # (OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,)
[//]: # (ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR)
[//]: # (OTHER DEALINGS IN THE SOFTWARE.)


## Procedure Title

This documents two possible formats for structing a list of steps in a procedure. Try not to mix both in same topic.


- Steps are an ordered list - Indentation is important.
  Everything aligns with first character of list.
  Best used when there are many (>10) short steps, but little text or code blocks associated with each step.
  See [Steps are an ordered list](#steps-are-an-ordered-list).
  
  
- Steps are headers - Text alignment and code block alignment is left justified.  Indentation not usually necessary.
  Best used when there are few long steps, and lots of text and code blocks.
  See [Steps are headers](#steps-are-headers).


### Steps are an ordered list

1. Do A
1. Do B
1. Do C
1. And on and on


### Steps are headers

This procedure will [describe what the user will achieve by the end of the guide]. [Explain goal, domain-related background information, any information that helps understand the purpose or terminology of the quickstart guide.]

[Purpose of procedure/title] is a [number of large steps, e.g. two]-step process:

* [step 1 short description, format VERB the/a(n)/your NOUN]
* [step 2 short description, format VERB the/a(n)/your NOUN]

#### Step 1: [Step 1 short description]

[Detailed description of what the user has to do in this step, including all necessary background information and domain-knowledge. Can contain descriptions, bulleted and numbered lists, screenshots, links.]

#### Step 2: [Step 2 short description]

[Detailed description of what the user has to do in this step, including all necessary background information and domain-knowledge. Can contain descriptions, bulleted and numbered lists, screenshots, links.]

#### Step m: [Step m short description]

[Detailed description of what the user has to do in this step, including all necessary background information and domain-knowledge. Can contain descriptions, bulleted and numbered lists, screenshots, links.]

This is a unordered list. Typically used for lists of conditions, or anything
not requring a specific sequence.

- This is unordered list
- Here is more

[Detailed description of what the user has to do in this step, including all necessary background information and domain-knowledge. Can contain descriptions, bulleted and numbered lists, screenshots, links.]

#### Step n: [Step n short description]

This step is formatted using substeps that are headers.

##### Act on A

```bash
ls -l
```

##### Act on B

```bash
ls -l
```

##### Act on C

```bash
ls -l
```

#### Step o: [Step o short description] 

If a=true then 

```bash
ls def  
```

Otherwise, 

```bash
ls -R def  
```

#### Step p: [Step p short description]

This is a conditional complex procedure

Do A or B or C depending on x and y.

If x and y are true, do [Procedure A](#procedure-a).

If either one, but not both of x and y, do [Procedure B](#procedure-b).

If both x and y are false, do [Procedure C](#procedure-c).


##### Procedure A

Configure the abc:

  ```bash
  ls
  ```

  ```bash
  ls
  ```

  ```bash
  ls
  ```


##### Procedure B

Configure the qrs:

  ```bash
  ls
  ```

  ```bash
  ls
  ```

  ```bash
  ls
  ```

##### Procedure C 

Configure the xyz:

  ```bash
  ls -1
  ```

  ```bash
  ls -l
  ```

  ```bash
  ls -R
  ```

#### End 

Congratulations! You have [what the user has achieved]. You may now want to check out these resources:

* [Link to related topic]()
* [Link to related topic]()
* [Link to related topic]()
* [Link to related topic]()
* Link to related topic - max 5 links]()

