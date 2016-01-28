# 2016 Winter Advanced IO PS2 by Eliot Abrams, Hyunmin Park, Alexandre Sollaci

tic()

# Load data
using DataFrames
product = readtable("dataset_cleaned.csv")
population = readtable("population_data.csv")

# Define variables
x = product[:,3:6]
p = product[:,7]
z = product[:,8:13]
s0 = product[:,14]
s = product[:,2]
iv = hcat(x,z)

# Setting up the model
using JuMP
L = size(x,2)+size(z,2)
J = size(x,1)
N = L + J + 1 + size(x,2)
m = Model()


# theta = (g xi alpha beta)
@defVar(m,theta[1:N])
@setObjective(m,Min,sum{theta[l]^2,l=1:L})

# g = sum_j xi_j iv_j
l = 1
while l <= L
	@addConstraint(m,theta[l]==sum{theta[L+j]*iv[j,l],j=1:J}) 
	l += 1
end

# market share equations (loop)
j = 1
while j <= J
	@addNLConstraint(m,theta[L+j]==log(s[j])-log(s0[j])+theta[L+J+1]*p[j]-theta[L+J+2]*x[j,1]-theta[L+J+3]*x[j,2]-theta[L+J+4]*x[j,3]-theta[L+J+5]*x[j,4])
	j += 1
end

using Ipopt
setSolver(m,IpoptSolver(tol = 1e-10, max_iter = 200, output_file = "results.txt"))

for i=1:N
  setValue(theta[i],1)
end

status = solve(m)
print(status)

println("alpha = ", getValue(theta[539]))
println("beta = ", getValue(theta[540:543]))

toc()
