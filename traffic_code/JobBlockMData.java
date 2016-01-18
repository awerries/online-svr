/*     */ package TLC.control.intersection.transition;
/*     */ 
/*     */ import TLC.component.edge.IEdgeHeadEngine;
/*     */ import TLC.component.edge.ILocalEdgeInfoEngine;
/*     */ import TLC.component.edge.calibrate.EdgeCalibrationInfo;
/*     */ import TLC.component.edge.calibrate.IGetEdgeCalibrationInfoEngine;
/*     */ import TLC.component.edge.edgeinfo.ISnapshotEdgeInfoEngine;
/*     */ import TLC.component.junction.OD.phase.data.IPhaseInpEdgeDataEngine;
/*     */ import TLC.component.junction.structure.IInnerPhaseInpEdgeEngine;
/*     */ import TLC.component.junction.structure.PhaseEdgeSpaceMethods;
/*     */ import TLC.connect.IReadOutflowEngine;
/*     */ import TLC.data.packet.CountPacket;
/*     */ import TLC.data.packet.GenericPacketSequence;
/*     */ import TLC.data.packet.IPacketFeederEngine;
/*     */ import TLC.data.packet.MultiOccupyPacketStream;
/*     */ import TLC.global.BasicMath;
/*     */ import TLC.global.BasicMatrix;
/*     */ import TLC.global.BufferSetMethods;
/*     */ import TLC.global.IIntegerArrayEngine;
/*     */ import TLC.setting.ScaleSettings;
		  import TLC.global.*;
		  import static TLC.global.BasicLog.logger;
/*     */ 
/*     */ public class JobBlockMData
/*     */ {
/*     */   public int[][] NumJob;
/*     */   public double[][][] PhaseWeights;
/*     */   public int[][][] PhaseJobStarts;
/*     */   public int[][][] PhaseJobEnds;
            public double [] PhaseInfo;
/*  30 */   private int maxExtHorizon = 0;
/*  31 */   private double scaleRatio = 1000.0D;
/*     */   private double[][] EdgeWeights;
/*     */   private int[][] EdgeJobStarts;
/*     */   private int[][] EdgeJobEnds;
/*     */   private int[] EdgeJobNumbers;
/*     */   private double[] edgeQueues;
/*     */   private IPhaseInpEdgeDataEngine phaseInpEdgeDataEngine;
/*     */   private IInnerPhaseInpEdgeEngine innerPhaseInpEdgeEngine;
/*     */   private IInnerPhaseInpEdgeEngine innerActiveInpEdgeEngine;
/*     */   private IReadOutflowEngine readOutflowHandler;
/*     */   private int [] EdgeInfo;

/*     */   public void initiate(int maxLocalHorizon, int maxExtHorizon, double scaleRatio, IInnerPhaseInpEdgeEngine innerPhaseInpEdgeEngine, IInnerPhaseInpEdgeEngine innerActiveInpEdgeEngine, IPhaseInpEdgeDataEngine phaseInpEdgeDataEngine, IReadOutflowEngine readOutflowHandler)
/*     */   {
/*  47 */     this.phaseInpEdgeDataEngine = phaseInpEdgeDataEngine;
/*  48 */     this.innerPhaseInpEdgeEngine = innerPhaseInpEdgeEngine;
/*  49 */     this.innerActiveInpEdgeEngine = innerActiveInpEdgeEngine;
/*  50 */     int edgeNumber = innerPhaseInpEdgeEngine.getInpEdgeNumber();
/*     */ 
/*  52 */     this.maxExtHorizon = maxExtHorizon;
/*  53 */     this.scaleRatio = scaleRatio;
/*  54 */     int maxJobNumber = BasicMath.ratioedRint(maxExtHorizon + 1000 + maxLocalHorizon, scaleRatio) + 1;
/*  55 */     this.EdgeWeights = new double[edgeNumber][maxJobNumber];
/*  56 */     this.EdgeJobStarts = new int[edgeNumber][maxJobNumber];
/*  57 */     this.EdgeJobEnds = new int[edgeNumber][maxJobNumber];
/*  58 */     this.EdgeJobNumbers = new int[edgeNumber];
/*  59 */     this.edgeQueues = new double[edgeNumber];
/*  60 */     this.PhaseWeights = new double[maxJobNumber][][];
/*  61 */     this.PhaseJobStarts = new int[maxJobNumber][][];
/*  62 */     this.PhaseJobEnds = new int[maxJobNumber][][];
              this.EdgeInfo = new int[edgeNumber];

/*     */ 
/*  64 */     int[] routeStructure = PhaseEdgeSpaceMethods.getPhaseInpEdgeSpaceStructure(innerPhaseInpEdgeEngine);
/*  65 */     for (int i = 0; i < maxJobNumber; i++) {
/*  66 */       this.PhaseWeights[i] = BasicMatrix.initDMatrix(routeStructure);
/*  67 */       this.PhaseJobStarts[i] = BasicMatrix.initIMatrix(routeStructure);
/*  68 */       this.PhaseJobEnds[i] = BasicMatrix.initIMatrix(routeStructure);
/*     */     }
/*  70 */     this.NumJob = BasicMatrix.initIMatrix(routeStructure);
              int internalPhaseNumber = this.innerPhaseInpEdgeEngine.getInternalPhaseNumber();
              this.PhaseInfo = new double[internalPhaseNumber];
/*     */ 
/*  72 */     this.readOutflowHandler = readOutflowHandler;
/*     */   }
/*     */ 
/*     */   public double getJobWeight(int i, int[] mJobID, int[] routeIndices) {
/*  76 */     return this.PhaseWeights[mJobID[i]][i][routeIndices[i]];
/*     */   }
/*     */ 
/*     */   public int getJobStart(int i, int[] mJobID, int[] routeIndices) {
/*  80 */     return this.PhaseJobStarts[mJobID[i]][i][routeIndices[i]];
/*     */   }
/*     */ 
/*     */   public int getJobEnd(int i, int[] mJobID, int[] routeIndices) {
/*  84 */     return this.PhaseJobEnds[mJobID[i]][i][routeIndices[i]];
/*     */   }
/*     */ 
/*     */   public double getTotalCount() {
/*  88 */     double totalCount = 0.0D;
/*  89 */     int internalPhaseNumber = this.innerPhaseInpEdgeEngine.getInternalPhaseNumber();
/*  90 */     for (int i = 0; i < internalPhaseNumber; i++) {
/*  91 */       for (int j = 0; j < this.innerPhaseInpEdgeEngine.getInternalInpEdgeNumber(i); j++) {
/*  92 */         for (int k = 0; k < this.NumJob[i][j]; k++) {
/*  93 */           totalCount += this.PhaseWeights[k][i][j];
/*     */         }
/*     */       }
/*     */     }
/*  97 */     return totalCount;
/*     */   }
/*     */ 
/*     */   public void initJobs(int StartRoute, int decisionTime, PhaseEdgeInfo phaseEdgeInfo, IEdgeHeadEngine[] inpEdgeSnapshotSet, IGetEdgeCalibrationInfoEngine inpEdgeStatus, PhaseExtensionChecker phaseExtensionChecker, boolean useQCBlockFlag)
/*     */   {
              String edgeInfo = "";
              double outflowCount = 0.0D;
              int outflowIndex;
              double inflowCount = 0.0D;
              double totalCount = 0.0D;
             

/* 102 */     for (int i = 0; i < inpEdgeSnapshotSet.length; i++) {
                outflowCount = 0.0D;
                inflowCount = 0.0D;
                edgeInfo = "";
                outflowIndex = -1;

/* 103 */       this.edgeQueues[i] = inpEdgeSnapshotSet[i].getSnapshotEdgeInfo().getQueueCount();
/* 104 */       IPacketFeederEngine packetFeederEngine = inpEdgeSnapshotSet[i].getSnapshotEdgeInfo().getPacketData();
/* 105 */       double speed = inpEdgeSnapshotSet[i].getMeanFlowSpeed(decisionTime);
/* 106 */       this.EdgeJobNumbers[i] = BufferSetMethods.getSize(packetFeederEngine);
/*     */ 
/* 108 */       int jIndex = 0;
/* 109 */       for (int j = 0; j < this.EdgeJobNumbers[i]; j++) {
/* 110 */         CountPacket packet = packetFeederEngine.getElementAt(packetFeederEngine.getFirstIndex() + j);
/* 111 */         if (packet.getDuration() == 0) {
/* 112 */           this.EdgeJobNumbers[i] -= 1;
/*     */         }
/*     */         else {
/* 115 */           this.EdgeJobStarts[i][jIndex] = BasicMath.ratioedRint(packet.start_V, this.scaleRatio * speed);
/* 116 */           this.EdgeJobEnds[i][jIndex] = BasicMath.ratioedRint(packet.end_V, this.scaleRatio * speed);
/* 117 */           this.EdgeWeights[i][jIndex] = packet.count;
                    inflowCount += packet.count;
                    //edgeInfo +="InflowJob ["+i+","+j+","+packet.count+"] StartEnd: ["+ this.EdgeJobStarts[i][jIndex]+", "+this.EdgeJobEnds[i][jIndex]+"] ";
/* 118 */           jIndex++;
/*     */         }
/*     */       }
				

/* 121 */       if (SDPSettings.UseUpstreamFlag > 1)
/*     */       {
/* 123 */         int betweenDTime = decisionTime - inpEdgeSnapshotSet[i].getSituatedArrivalOccupyPacketFeeder().getMaxBoundValue();
/*     */ 
/* 125 */         GenericPacketSequence upstreamOutflow = this.readOutflowHandler.getOutFlow(i, decisionTime - betweenDTime, this.maxExtHorizon + betweenDTime);
/* 126 */         int offsetTime = (int)(inpEdgeSnapshotSet[i].getLocalEdgeInfo().getEdgeLength() / inpEdgeSnapshotSet[i].getMeanFlowSpeed(decisionTime)) - betweenDTime;
/* 127 */         if (upstreamOutflow != null) {
/* 128 */           for (int kk = 0; kk < upstreamOutflow.getSize(); kk++) {
/* 129 */             CountPacket packet = (CountPacket)upstreamOutflow.getElementAt(kk);
                      //BasicLog.getLogger("OutFlow").info("Packet count: "+packet.count); 
/* 130 */             if (packet.count != 0.0D) {
                        if(outflowIndex == -1)
                          outflowIndex = this.EdgeJobNumbers[i];
/* 131 */               this.EdgeJobStarts[i][this.EdgeJobNumbers[i]] = BasicMath.ratioedRint(packet.start_V + offsetTime, this.scaleRatio);
/* 132 */               this.EdgeJobEnds[i][this.EdgeJobNumbers[i]] = BasicMath.ratioedRint(packet.end_V + offsetTime, this.scaleRatio);
/* 133 */               this.EdgeWeights[i][this.EdgeJobNumbers[i]] = packet.count;
                        outflowCount += packet.count;
                        //edgeInfo += "OutFlowJob ["+i+","+this.EdgeJobNumbers[i]+","+packet.count+"] StartEnd: ["+ this.EdgeJobStarts[i][this.EdgeJobNumbers[i]]+", "+this.EdgeJobEnds[i][this.EdgeJobNumbers[i]]+"] ";
/* 134 */               if (this.EdgeJobEnds[i][this.EdgeJobNumbers[i]] == this.EdgeJobStarts[i][this.EdgeJobNumbers[i]]) {
/* 135 */                 this.EdgeJobEnds[i][this.EdgeJobNumbers[i]] += 1;
/*     */               }
/* 137 */               this.EdgeJobNumbers[i] += 1;
/*     */             }
/*     */           }
/*     */         }
                  //else
                  //BasicLog.getLogger("OutFlow").info("No Outflow"); 
/*     */       }
               this.EdgeInfo[i] = outflowIndex;
               //BasicLog.getLogger("OutFlow").info(decisionTime+" Edge =" + i + ", inflowCount =" + inflowCount +", outflowCount ="+ outflowCount);//+" | "+edgeInfo);
/*     */     }
/*     */     
/* 144 */     int edgeIndex = 0;
/*     */     
/* 147 */     int internalPhaseNumber = this.innerPhaseInpEdgeEngine.getInternalPhaseNumber();
              
/* 148 */     for (int i = 0; i < internalPhaseNumber; i++) {
/* 149 */       int inpEdgeNumber = this.innerPhaseInpEdgeEngine.getInternalInpEdgeNumber(i);
              
                this.PhaseInfo[i] = 0.0D;
/* 150 */       for (int j = 0; j < inpEdgeNumber; j++) {
/* 151 */         edgeIndex = this.innerPhaseInpEdgeEngine.getActualInpEdgeIndexAt(i, j);
/* 152 */         int internalActiveEdgeIndex = this.innerActiveInpEdgeEngine.getInternalInpEdgeIndexAt(i, edgeIndex);
/* 153 */         double phaseEdgeRatio = this.phaseInpEdgeDataEngine.getPhaseInpEdgeFlowRatioAt(i, internalActiveEdgeIndex);
/* 154 */         double weightedCount = this.edgeQueues[edgeIndex] * phaseEdgeRatio;
/* 155 */         IIntegerArrayEngine phaseIndices = this.innerPhaseInpEdgeEngine.getInpEdgePhaseIndices(edgeIndex);
/* 156 */         if ((i == StartRoute) && (phaseIndices.getSize() > 1) && (i == phaseIndices.getValueAt(phaseIndices.getSize() - 1))) {
/* 157 */           weightedCount = this.edgeQueues[edgeIndex];
/*     */         }
/* 159 */         this.NumJob[i][j] = 0;
/* 160 */         int prevEnd = 0;
/* 161 */         if ((i == StartRoute) && (useQCBlockFlag) && (inpEdgeStatus.getEdgeCalibrationInfoAt(edgeIndex).blockState)) {
/* 162 */           prevEnd += BasicMath.ratioedRint(SDPSettings.BlockedDelay, this.scaleRatio);
/*     */         }
/* 164 */         if (weightedCount > ScaleSettings.MinVehCount) {
/* 165 */           this.PhaseJobStarts[0][i][j] = prevEnd;
/* 166 */           this.PhaseJobEnds[0][i][j] = (this.PhaseJobStarts[0][i][j] + (int)Math.rint(weightedCount / phaseEdgeInfo.satFlowRates[i][j]));
/* 167 */           this.PhaseWeights[0][i][j] = weightedCount;
/* 168 */           this.NumJob[i][j] += 1;
/*     */         }
/* 170 */         for (int k = 0; k < this.EdgeJobNumbers[edgeIndex]; k++) {
/* 171 */           weightedCount = this.EdgeWeights[edgeIndex][k] * phaseEdgeRatio;
/* 172 */           if (weightedCount > ScaleSettings.MinVehCount) {
/* 173 */             int deltaT = 0;
/* 174 */             if (this.NumJob[i][j] > 0) prevEnd = this.PhaseJobEnds[(this.NumJob[i][j] - 1)][i][j];
/* 175 */             int jLength = this.EdgeJobEnds[edgeIndex][k] - this.EdgeJobStarts[edgeIndex][k];
/* 176 */             if (SDPSettings.UseAnticipate) {
/* 177 */               deltaT = JobBlockHandler.getDeltaT(this.EdgeJobStarts[edgeIndex][k], jLength, weightedCount, prevEnd, phaseEdgeInfo.satFlowRates[i][j]);
/*     */             }
/* 179 */             if (deltaT > 0) {
/* 180 */               if (this.NumJob[i][j] == 0) {
/* 181 */                 this.PhaseJobStarts[0][i][j] = prevEnd;
/* 182 */                 this.PhaseJobEnds[0][i][j] = prevEnd;
/* 183 */                 this.PhaseWeights[0][i][j] = 0.0D;
/* 184 */                 this.NumJob[i][j] += 1;
/*     */               }
/* 186 */               double deltaWeight = Math.min(weightedCount, weightedCount * deltaT / jLength);
/* 187 */               this.PhaseWeights[(this.NumJob[i][j] - 1)][i][j] += deltaWeight;
                        //BasicLog.getLogger("OutFlow").info("bp1 "+edgeIndex+" outflow start from"+this.EdgeInfo[edgeIndex]+" k"+k+" "+deltaWeight);
                        if(k >= this.EdgeInfo[edgeIndex] && this.EdgeInfo[edgeIndex] != -1 )
                          this.PhaseInfo[i] += deltaWeight;        
/* 188 */               this.PhaseJobEnds[(this.NumJob[i][j] - 1)][i][j] += (int)Math.rint(deltaWeight / phaseEdgeInfo.satFlowRates[i][j]);
/* 189 */               if (deltaT < jLength) {
/* 190 */                 this.PhaseJobStarts[this.NumJob[i][j]][i][j] = (this.EdgeJobStarts[edgeIndex][k] + deltaT);
/* 191 */                 this.PhaseJobEnds[this.NumJob[i][j]][i][j] = this.EdgeJobEnds[edgeIndex][k];
/* 192 */                 this.PhaseWeights[this.NumJob[i][j]][i][j] = (weightedCount - weightedCount * deltaT / jLength);
                          //BasicLog.getLogger("OutFlow").info("bp2 "+edgeIndex+" outflow start from"+this.EdgeInfo[edgeIndex]+" k"+k+" "+this.PhaseWeights[this.NumJob[i][j]][i][j]);
                          if(k >= this.EdgeInfo[edgeIndex] && this.EdgeInfo[edgeIndex] != -1 )
                            this.PhaseInfo[i] += this.PhaseWeights[this.NumJob[i][j]][i][j];  
/* 193 */                 this.NumJob[i][j] += 1;
/*     */               }
/*     */             }
/* 196 */             if (deltaT <= 0) {
/* 197 */               this.PhaseJobStarts[this.NumJob[i][j]][i][j] = this.EdgeJobStarts[edgeIndex][k];
/* 198 */               this.PhaseJobEnds[this.NumJob[i][j]][i][j] = this.EdgeJobEnds[edgeIndex][k];
/* 199 */               this.PhaseWeights[this.NumJob[i][j]][i][j] = weightedCount;
                        //BasicLog.getLogger("OutFlow").info("bp3 "+edgeIndex+" outflow start from"+this.EdgeInfo[edgeIndex]+" k"+k+" "+weightedCount);
                        if(k >= this.EdgeInfo[edgeIndex] && this.EdgeInfo[edgeIndex] != -1 )
                            this.PhaseInfo[i] += this.PhaseWeights[this.NumJob[i][j]][i][j];
/* 200 */               this.NumJob[i][j] += 1;
/*     */             }
/*     */           }
/*     */         }
                  for (int k = 0; k < this.NumJob[i][j]; k++)
                    BasicLog.getLogger("OutFlow").info(decisionTime+" "+i+" "+j+" "+edgeIndex+" "+this.PhaseWeights[k][i][j]+" "+this.PhaseJobStarts[k][i][j]+" "+this.PhaseJobEnds[k][i][j]);

/* 204 */         if (SDPSettings.UseSatHeadway)
/* 205 */           for (int k = 0; k < this.NumJob[i][j]; k++)
/* 206 */             this.PhaseJobEnds[k][i][j] = Math.max((int)Math.rint(this.PhaseWeights[k][i][j] / phaseEdgeInfo.satFlowRates[i][j]) + this.PhaseJobStarts[k][i][j], this.PhaseJobEnds[k][i][j]);
/*     */       }
                
                 
                //BasicLog.getLogger("OutFlow").info(decisionTime+" PhaseInfo["+i+","+this.PhaseInfo[i]+"]");//+" phaseOutflowInd ["+phaseOutflowInd_str+"]"+" EdgeInfo ["+edgeInfo_str+"]");
/*     */     }

/*     */   }
            public JobInfo getJobInfo(int phase, int edge, int job)
            {
              JobInfo info = new JobInfo();
              info.phaseInfo = this.PhaseInfo[phase];
              return info;
            }


/*     */ }

/* Location:           /usr0/home/ahawkes/DecTLC-devel.jar
 * Qualified Name:     TLC.control.intersection.transition.JobBlockMData
 * JD-Core Version:    0.6.2
 */