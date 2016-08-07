material `TunnelInner` { diffuseMap=`TunnelInner.dds` }
material `TunnelOuter` { diffuseMap=`TunnelOuter.dds` }
material `TunnelCap` { diffuseMap=`TunnelCap.dds` }
material `TunnelSide` { diffuseMap=`TunnelSide.dds` }
material `FinishLine` { diffuseMap=`FinishLine.dds` }
material `TrackApexArrow` { diffuseMap=`TrackApexArrow.dds` }
material `UnderSide` { diffuseMap=`UnderSide.dds` }
material `PadBase` { diffuseMap=`PadBase.dds` }

-- there appear to be latent problems with emissive and alpha channels here.

material `Barrier` { diffuseMap=`Barrier.dds`, alpha=true, emissiveMap=`Barrier.dds`, emissiveMask=vec(1,1,1), alphaReject=0.4, additionalLighting=true }
material `NeonRed` { diffuseMap=`NeonRed.dds`, emissiveMap=`NeonRed.dds`, emissiveMask=vec(1,1,1), additionalLighting=true }
material `NeonGreen` { diffuseMap=`NeonRed.dds`, emissiveMap=`NeonGreen.dds`, emissiveMask=vec(1,1,1), additionalLighting=true }
material `Glass` { diffuseMap=`Glass.dds`, alpha=true }

sky_material `Sky` {
    emissiveMap = `FunkyStarField.dds`,
}
