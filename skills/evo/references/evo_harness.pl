% EVO harness: Prolog-first derivation with explicit assumptions and proofs.
%
% This harness is intentionally minimal and is designed to be embedded into a
% temporary Prolog program by tools/scripts.
%
% Expected user KB predicates (zero or more):
% - observation/1, claim/1, premise/1
% - rule/3: rule(Name, Head, BodyGoalsList).
% - assumption/2: assumption(Name, Goal).
% - constraint/2: constraint(Name, ViolatingGoal).
% - contradiction/2: contradiction(GoalA, GoalB).  % optional
% - enabled_assumption/1 facts may be injected by tooling.
% - conclusion/1 must be provided by the user KB (directly or via rules).

:- dynamic enabled_assumption/1.
:- dynamic observation/1.
:- dynamic claim/1.
:- dynamic premise/1.
:- dynamic rule/3.
:- dynamic assumption/2.
:- dynamic constraint/2.
:- dynamic contradiction/2.
:- dynamic conclusion/1.

:- discontiguous observation/1.
:- discontiguous claim/1.
:- discontiguous premise/1.
:- discontiguous rule/3.
:- discontiguous assumption/2.
:- discontiguous constraint/2.
:- discontiguous contradiction/2.
:- discontiguous conclusion/1.

active_assumption(Name) :-
    enabled_assumption(Name).

% -------------------------
% Derivation / proof tracing
% -------------------------

prove(Goal, Proof) :-
    prove_(Goal, Proof, []).

prove_(Goal, [Step], _Visited) :-
    observation(Goal),
    proof_step("observation", Goal, Step).
prove_(Goal, [Step], _Visited) :-
    claim(Goal),
    proof_step("claim", Goal, Step).
prove_(Goal, [Step], _Visited) :-
    premise(Goal),
    proof_step("premise", Goal, Step).
prove_(Goal, [Step], _Visited) :-
    assumption(Name, Goal),
    active_assumption(Name),
    proof_step_assumption(Name, Goal, Step).
prove_(Goal, [Step | Rest], Visited) :-
    rule(Name, Goal, Body),
    \+ memberchk(Goal, Visited),
    prove_all(Body, Rest, [Goal | Visited]),
    proof_step_rule(Name, Goal, Step).
prove_(Goal, [Step], _Visited) :-
    predicate_property(Goal, built_in),
    call(Goal),
    proof_step("builtin", Goal, Step).

prove_all([], [], _Visited).
prove_all([G | RestGoals], Proof, Visited) :-
    prove_(G, Proof1, Visited),
    prove_all(RestGoals, Proof2, Visited),
    append(Proof1, Proof2, Proof).

goal_string(Goal, S) :-
    term_string(Goal, S, [quoted(true), numbervars(true)]).

conclusion_with_proof(Answer, Proof) :-
    prove(conclusion(AnswerTerm), Proof),
    goal_string(AnswerTerm, Answer).

proof_step(Tag, Goal, Step) :-
    goal_string(Goal, GS),
    format(string(Step), "~w: ~s", [Tag, GS]).

proof_step_rule(Name, Head, Step) :-
    goal_string(Head, HS),
    format(string(Step), "rule(~w): ~s", [Name, HS]).

proof_step_assumption(Name, Goal, Step) :-
    goal_string(Goal, GS),
    format(string(Step), "assumption(~w): ~s", [Name, GS]).

% -------------------------
% Consistency
% -------------------------

holds(Goal) :-
    prove(Goal, _).

inconsistent :-
    constraint(Name, ViolatingGoal),
    holds(ViolatingGoal),
    format(string(_), "constraint(~w) violated", [Name]),
    !.
inconsistent :-
    contradiction(A, B),
    holds(A),
    holds(B),
    !.

% -------------------------
% Solved gate (lightweight)
% -------------------------
%
% solved(Status, Summary) is intentionally permissive: it only checks that at
% least one conclusion can be derived with a proof and that the KB is
% consistent. Assumption-dependence testing and formalization completeness are
% expected to be orchestrated by higher-level tooling and/or the agent.

solved(solved, "conclusion derivable and consistent") :-
    \+ inconsistent,
    conclusion(_),
    prove(conclusion(_), _),
    !.
solved(mapped, "no derivable conclusion") :-
    \+ conclusion(_),
    !.
solved(candidate, "unable to certify solved gate") :-
    !.
