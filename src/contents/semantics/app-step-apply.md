$$
\cfrac{\quad \Jval{x}}{\EApp{\ELambda{x}{e}}{e_2} \step \subst{e_2}{x}{e}}
$$

#### Explanation
For a function application $\EAppC{(\ELambdaC{x}{e})}{e_2}$,
if the expression `e_2` is already a value,
when stepping $\EAppC{(\ELambdaC{x}{e})}{e_2}$,
the result is a substitution of the parameter `x` by argument `e_2` in the function body `e`.