# Blockscout
## Known Issues

🛑 Unfortunately, we must inform you that our project is no longer maintained and there is no current plan to address these issues.   
### Unhandled division by zero
Synchronization throws the following error in logs:  
indexer.block.fetcher.import throws ArithmeticError bad argument during synchronization.  
   
An upstream fix was developed in Pull Request #6599, but merging was causing deploying issues, so the fix wasn't applied.
### Root node not found
Eventual high use of CPU and RAM.  
The log is flooded with messages like  
0x6996d8bd18637f5e3a64c4f7232de94c0a15a1bc@⫄: (3) Execution error  
CPU usage goes high and large amounts of RAM are consumed. This message also appears:  
MissingNodeException: Root node not found  
This is not a crashing bug.