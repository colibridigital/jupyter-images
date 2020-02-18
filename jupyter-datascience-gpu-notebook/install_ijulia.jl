using Pkg
# Julia Kernel
ENV["JUPYTER"]="/opt/conda/bin/jupyter";
Pkg.add("IJulia");
Pkg.build("IJulia");
