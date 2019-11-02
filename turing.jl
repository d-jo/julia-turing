
struct TuringMachine
	Q::Int64
	Σ::Array{Any}
	Γ::Array{Any}
	δ::Any
	Start::Int64
	Accept::Int64
	Reject::Int64
end

mutable struct Configuration
	CurrentState::Int64
	CurrentHeadIndex::Int64
	Tape::Array{Any}
end


# rules are a dict (qi,headCharacter)=>(qj, writeBuff, headOffset)


function generateStaticδ(rules)
	unbuiltExpressions = []
	for k in keys(rules)
		currentRuleDest = rules[k]
		push!(unbuiltExpressions, quote
						if $(k[1]) == currentConfig.CurrentState && $(k[2]) == currentConfig.Tape[currentConfig.CurrentHeadIndex]
							if $(currentRuleDest[2]) != nothing
								currentConfig.Tape[currentConfig.CurrentHeadIndex] = $(currentRuleDest[2])
							end
							currentConfig.CurrentHeadIndex += $(currentRuleDest[3])
							currentConfig.CurrentState = $(currentRuleDest[1])
							executed = true
							return
						end
					end)
	end
	return Expr(:call, unbuiltExpressions...)
end



currentConfig = Configuration(1, 1, [0,0,0,0,0])
delta = Dict((1,0)=>(2, 1, 1), (1,1)=>(2, 3, 1), (2,0)=>(1, 1, 1))
a = generateStaticδ(delta)
dump(a)
eval(a)
dump(currentConfig)
eval(a)
dump(currentConfig)
eval(a)
dump(currentConfig)
