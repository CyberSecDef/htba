# Technical Report: The Penetration Testing Process

## 1. Definition of a Process in Penetration Testing

In its broadest sense, a **process** is a directed and structured sequence of events designed to achieve a specific goal within a defined time frame. Across disciplines:

* In **social sciences**, a process describes a sequence of related actions or events.
* In **organizational contexts**, it represents business or operational workflows.
* In **computer systems**, processes are programs executing tasks as part of system software.

Penetration testing borrows from the **social science definition**, as it represents a sequence of deliberate actions guided by observations and outcomes. Each step is influenced by what the tester discovers or provokes during testing.

---

## 2. Deterministic vs Stochastic Processes

The document distinguishes between two types of processes:

* **Deterministic processes**
  Each state is causally dependent on previous events. Given the same inputs, the outcome is predictable.

* **Stochastic processes**
  Outcomes are probabilistic and influenced by randomness or uncertainty.

Penetration testing aligns more closely with **deterministic processes**. While the environment may be complex, each step is driven by concrete findings, observable behavior, and deliberate tester actions.

---

## 3. Definition of the Penetration Testing Process

A **penetration testing process** is defined as a sequence of structured, goal-oriented steps carried out by a penetration tester to reach a predefined objective, such as:

* Gaining unauthorized access
* Demonstrating data exposure
* Assessing impact on confidentiality, integrity, or availability

Crucially, this process is **not a fixed recipe** or a rigid step-by-step guide. Instead, it must remain:

* Coarse-grained
* Flexible
* Adaptable to unique client environments

Every client’s infrastructure, risk tolerance, and expectations differ, making adaptability essential.

---

## 4. Limitations of Circular Process Models

Penetration testing processes are often depicted as **circular models**. While visually intuitive, these models have inherent limitations:

* If one component fails, the entire loop appears broken
* Restarting the loop with new information creates a *new* process, not a continuation
* Circular models offer little guidance for extending or adapting methodology mid-test

The document emphasizes that penetration testing must allow for **fallbacks, branching paths, and iterative refinement**, which circular diagrams often fail to represent effectively.

---

## 5. Stage-Based Penetration Testing Model

To address these issues, the document introduces a **stage-based process**. Each stage:

* Builds upon the previous one
* Can be revisited iteratively
* Supports adaptation without invalidating prior work

The core penetration testing stages are:

1. Pre-Engagement
2. Information Gathering
3. Vulnerability Assessment
4. Exploitation
5. Post-Exploitation
6. Lateral Movement
7. Proof-of-Concept
8. Post-Engagement

This structure provides both **direction and flexibility**.

---

## 6. Optional Study Plan and Iterative Learning

The document describes an optional study plan aligned with the stages of the penetration testing process. This plan emphasizes:

* Modular learning
* Progressive skill development
* Iteration across phases such as information gathering, post-exploitation, and lateral movement

Knowledge gaps in any stage—regardless of perceived familiarity—can lead to misunderstandings or failures later in the process. Therefore, each stage demands focused attention.

---

## 7. Detailed Breakdown of Penetration Testing Stages

### 7.1 Pre-Engagement

**Purpose:**
Define and formalize the engagement.

**Key activities include:**

* Educating the client
* Adjusting and finalizing the contract
* Clarifying expectations and limitations

**Common deliverables:**

* Non-Disclosure Agreement (NDA)
* Defined goals and objectives
* Scope of testing
* Time estimates
* Rules of Engagement (RoE)

This stage establishes **legal, technical, and ethical boundaries**.

---

### 7.2 Information Gathering

**Purpose:**
Collect intelligence on the target organization, systems, and technologies.

**Activities include:**

* Identifying software and hardware in use
* Mapping services and interfaces
* Understanding how the target operates

The goal is to uncover **potential security gaps** that could be leveraged later.

---

### 7.3 Vulnerability Assessment

**Purpose:**
Analyze gathered information to identify weaknesses.

**Key aspects:**

* Identification of known vulnerabilities
* Manual and automated analysis
* Evaluation of system and application versions

This stage assesses the **likelihood and impact** of potential attack vectors.

---

### 7.4 Exploitation

**Purpose:**
Validate vulnerabilities by attempting controlled exploitation.

**Activities include:**

* Preparing exploit code and tools
* Testing attack vectors against target systems
* Achieving initial access where possible

Exploitation is performed **carefully and deliberately** to avoid unnecessary disruption.

---

### 7.5 Post-Exploitation

**Purpose:**
Expand access and demonstrate impact after initial compromise.

**Common objectives:**

* Maintain persistence
* Escalate privileges
* Collect sensitive data (pillaging)
* Assess internal security posture

Post-exploitation often feeds directly into lateral movement activities.

---

### 7.6 Lateral Movement

**Purpose:**
Move within the internal network to access additional systems.

**Typical activities:**

* Using harvested credentials
* Enumerating internal services
* Accessing systems at equal or higher privilege levels

Lateral movement is often **iterative**, combining enumeration and exploitation repeatedly until objectives are met.

---

### 7.7 Proof-of-Concept

**Purpose:**
Demonstrate and document how vulnerabilities were chained together.

**Key deliverables:**

* Step-by-step attack paths
* Clear explanation of each weakness
* Optional automation scripts

This stage is critical for:

* Client understanding
* Remediation prioritization
* Validation of findings

Poor documentation significantly reduces the value of a pentest.

---

### 7.8 Post-Engagement

**Purpose:**
Conclude the engagement professionally and responsibly.

**Activities include:**

* Final report preparation
* Executive summaries and technical breakdowns
* Cleanup of artifacts and access
* Report walkthrough meetings
* Archiving testing data per contract and policy

Post-engagement ensures **knowledge transfer** and supports remediation efforts.

---

## 8. Practical Example: Web Application Testing

The document illustrates how the stages apply to a web application assessment:

* Pre-engagement defines scope and rules
* Information gathering identifies technologies and application behavior
* Vulnerability assessment locates flaws
* Exploitation validates weaknesses
* Post-exploitation reveals internal data
* Lateral movement explores connected systems
* Proof-of-concept documents attack paths
* Post-engagement delivers results to the client

This reinforces the **dependency of each stage on the previous one**.

---

## 9. Importance of Internalizing the Process

The penetration testing process is more than a checklist—it is a **mental framework**. Internalizing it allows testers to:

* Identify weaknesses in their own skill sets
* Recognize where they struggle most
* Improve efficiency and accuracy
* Maintain consistency across engagements

Each stage highlights specific competencies that can be refined independently.

---

## 10. Conclusion

The penetration testing process described in the document provides a **structured yet adaptable framework** for conducting professional security assessments. By emphasizing stages over rigid steps, it accommodates the complexity and variability of real-world environments while maintaining methodological discipline.

A successful penetration test depends not on tools alone, but on **process awareness, iterative learning, and precise execution**. Internalizing this process is essential for delivering meaningful, defensible, and high-impact security assessments .
