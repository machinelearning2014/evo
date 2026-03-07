% Template KB for EVO harness.
%
% Replace these stubs with task-specific facts, rules, assumptions, and a
% conclusion/1 predicate.

% --- Observations / Claims ---
% observation(parent(alice, bob)).
% claim(parent(bob, carol)).

% --- Rules ---
% rule(ancestor_base, ancestor(X, Y), [parent(X, Y)]).
% rule(ancestor_step, ancestor(X, Y), [parent(X, Z), ancestor(Z, Y)]).

% --- Assumptions (optional) ---
% assumption(allow_closed_world, neg(Goal), [\+ holds(Goal)]).
% (Prefer: assumption(Name, Goal). and gate it via enabled_assumption/1)

% --- Constraints / Contradictions (optional) ---
% constraint(no_self_parent, parent(X, X)).
% contradiction(p, not_p).

% --- Required: conclusions ---
% conclusion(answer(Who)) :-
%     ancestor(alice, Who).

