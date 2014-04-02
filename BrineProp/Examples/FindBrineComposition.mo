within BrineProp.Examples;
model FindBrineComposition
  "Finds brine composition mass fraction from infos in g/l"
package Medium = BrineProp.Brine_5salts_TwoPhase_3gas;
  Medium.BaseProperties props;

  SI.Density d_l(start=1200)= props.state.d_l;  /**/

/*    SI.Pressure p_degas_CO2=Medium.degassingPressure_CO2_Duan2003(props.p,props.T,props.X,Medium.MM_vec);
  SI.Pressure p_degas_N2=Medium.degassingPressure_N2_Duan2006(props.p,props.T,props.X,Medium.MM_vec);
  SI.Pressure p_degas_CH4=Medium.degassingPressure_CH4_Duan2006(props.p,props.T,props.X,Medium.MM_vec);
  */

  SI.MassConcentration TDS= sum(props.X_l[1:Medium.nX_salt])*props.d_l;
  SI.MassFraction[:] X_g=props.X-props.X_l*(1-props.x)
    "mass in gas phase per kg fluid";
  Real[:] y=props.p_gas/props.p "volume fraction of gas phase";
//  Real[:] yy=y[2:3]./fill(1-y[4],2) "volume fraction of gas phase w/o H2O";
//  Real[:] yy=(props.p_gas/props.p./{.038,.829,.128}-{1,1,1});
//  Real[:] xx=(X_g[6:8]-{5.87E-05,8.04E-04,7.14E-05})./{5.87E-05,8.04E-04,7.14E-05};
  Real[:] y_l=if not max(props.X_l[6:8])>0 then fill(0,Medium.nX_gas) else props.X_l[6:8]./Medium.MM_gas / sum(props.X_l[6:8]./Medium.MM_gas)
    "mol fraction of dissolved gases";
  Real V_l = sum(props.X_l[6:8]./Medium.MM_gas)*22.4/props.X_l[end]
    "Volume dissolved gas would have at standard conditions";

// Chloride concentrations in g per litre
//  SI.MassConcentration  c[:]={97.331,5.673,150.229,1.587,2.861} "STR04/16";
  constant SI.MassConcentration  c[:]={98.84925634,2.984821797,144.6515323,0*0.720790948,0*2.520416712}
    "Elvira 02/2013";

  //SI.MassFraction X_l_salt=c/props.state.d_l;

//  Real[:] gasVolumeFractions={0.03825,0.8285,0.12825};
  Real[:] gasVolumeFractions={0.0935,78.5,13.5};
  //Real GVF_measured = ;
  //Real gasLiquidRatio=0.8475 "GVF/(1-GVF)";
  Real gasLiquidRatio=0.690
                          /464.41 "GVF/(1-GVF)";
  Real gasVolumePerLiquidVolume[:]= gasVolumeFractions*gasLiquidRatio;
  SI.Density[:] rho_gas = props.p*Medium.MM_gas/(Modelica.Constants.R*props.T);
  Real gasMassPerLiquidMass[:]= gasVolumePerLiquidVolume.*rho_gas/props.state.d_l;
SI.MassConcentration[:] X_g_gas(each start=0)= gasMassPerLiquidMass/(1+sum(gasMassPerLiquidMass))
    "X_g�q gas mass in gas phase per fluid mass";
  // SI.MassConcentration[:] X_g_gas(each start=0)={max(0,g/(1+sum(g)))  for  g in  gasMassPerLiquidMass};
  SI.Pressure[:] PartialPressures(each start=1e4)=(props.p-props.p_H2O)*gasVolumeFractions;
  SI.MassConcentration[:] X_l_gas(each start=0)= {
    PartialGasData.solubility_CO2_pTX_Duan2006(props.p,props.T,props.X,Medium.MM_vec,PartialPressures[1]),
    PartialGasData.solubility_N2_pTX_Duan2006(props.p,props.T,props.X,Medium.MM_vec,PartialPressures[2]),
    PartialGasData.solubility_CH4_pTX_Duan2006(props.p,props.T,props.X,Medium.MM_vec,PartialPressures[3])}/(1-props.x)
    "gas mass in liquid phase per fluid mass";
/*  SI.MassConcentration[:] X_l_gas= {2.65E-08,3.61E-11,5.47E-11}.*PartialPressures;
*/
equation

  props.p = 1.01325e5 "STP";
  props.T = 273.16+23 "STP";
//  props.Xi = {0.081139965786705,0.00472896349276478,0.12523788358023,0.00132259893695478,0.0023849508647916,0.000155632999623811,0.000734311259761201,0.000065661724072916}
  props.Xi = cat(1,c/d_l/0.999190406582784,X_g_gas+X_l_gas) "props.state.d_l";

algorithm
  print("rho_l="+String(props.state.d_l)+" kg/m�, TDS = " + String(TDS) + " g/l");
  print("X=" + Modelica.Math.Matrices.toString({props.X}) + " ");

//  print("sum(X_l)="+String(sum(props.state.X_l)-1)+"");
end FindBrineComposition;