#include <iostream> 
#include <fstream>
#include <cmath> 
#include "math.h" 
#include "TCanvas.h"
#include "TFile.h"
#include "TTree.h"
#include "TChain.h"
#include "TH1.h"
#include "TH2.h"
#include "TH3.h"
#include "TF1.h"
#include "TH1F.h"
#include "TLorentzVector.h"
#include "TROOT.h"
#include "TStyle.h"
#include "TMinuit.h"
#include "TPaveText.h"
#include "TText.h"
#include "TSystem.h"
#include "TArc.h"
#include "TString.h"
#include <vector>
#include "TRandom3.h"
#include "TGraphErrors.h"
#include "TString.h"
#include "TFile.h"

using namespace std;

void analysis(string input_filename)
{
gROOT->Reset();
gStyle->SetPalette(1);
gStyle->SetOptStat(1111111);

const double DEG=180./3.1415926;

// string filemode;
// double event_actual=1;
// if (input_filename.find("BeamOnTarget",0) != string::npos) {
//   filemode="BeamOnTarget";
//   cout << "this is a BeamOnTarget file" << endl;  
//   
// //  event_actual=atof(input_filename.substr(input_filename.find("BeamOnTarget",0)+13,input_filename.find("_")).c_str());
// //  cout << "event_actual " << event_actual <<  endl;  
// }
// else {
//   cout << "this is not a BeamOnTarget file" << endl;  
//   return;
// }

char the_filename[200];
sprintf(the_filename, "%s",input_filename.substr(0,input_filename.rfind(".")).c_str());

//char output_filename[200];
//sprintf(output_filename, "%s_output.root",the_filename);
//TFile *outputfile=new TFile(output_filename, "recreate");

// TH1F *htotEdep[8][3];
// for(int i=0;i<8;i++){
//  for(int j=0;j<3;j++){
//   char hstname[100];
//   sprintf(hstname,"totEdep_%i_%i",i,j);
//   htotEdep[i][j]=new TH1F(hstname,hstname,100,0,10);
//  }
// }

TFile *file=new TFile(input_filename.c_str());
if (file->IsZombie()) {
    cout << "Error opening file" << input_filename << endl;
    exit(-1);
}
else cout << "open file " << input_filename << endl;    

TTree *tree_header = (TTree*) file->Get("header");
vector <int> *evn=0,*evn_type=0;
vector <double> *beamPol=0;
vector <int> *var1=0,*var2=0,*var3=0,*var4=0,*var5=0,*var6=0,*var7=0,*var8=0;
tree_header->SetBranchAddress("evn",&evn);
tree_header->SetBranchAddress("evn_type",&evn_type);
tree_header->SetBranchAddress("beamPol",&beamPol);
tree_header->SetBranchAddress("var1",&var1);
tree_header->SetBranchAddress("var2",&var2);
tree_header->SetBranchAddress("var3",&var3);
tree_header->SetBranchAddress("var4",&var4);
tree_header->SetBranchAddress("var5",&var5);
tree_header->SetBranchAddress("var6",&var6);
tree_header->SetBranchAddress("var7",&var7);
tree_header->SetBranchAddress("var8",&var8);

TTree *tree_generated = (TTree*) file->Get("generated");
vector <int> *gen_pid=0;
vector <double> *gen_px=0,*gen_py=0,*gen_pz=0,*gen_vx=0,*gen_vy=0,*gen_vz=0;
tree_generated->SetBranchAddress("pid",&gen_pid);
tree_generated->SetBranchAddress("px",&gen_px);
tree_generated->SetBranchAddress("py",&gen_py);
tree_generated->SetBranchAddress("pz",&gen_pz);
tree_generated->SetBranchAddress("vx",&gen_vx);
tree_generated->SetBranchAddress("vy",&gen_vy);
tree_generated->SetBranchAddress("vz",&gen_vz);

TTree *tree_eic_rich = (TTree*) file->Get("eic_rich");
vector<int> *eic_rich_id=0,*eic_rich_hitn=0;
vector<int> *eic_rich_pid=0,*eic_rich_mpid=0,*eic_rich_tid=0,*eic_rich_mtid=0,*eic_rich_otid=0;
vector<double> *eic_rich_trackE=0,*eic_rich_totEdep=0,*eic_rich_avg_x=0,*eic_rich_avg_y=0,*eic_rich_avg_z=0,*eic_rich_avg_lx=0,*eic_rich_avg_ly=0,*eic_rich_avg_lz=0,*eic_rich_px=0,*eic_rich_py=0,*eic_rich_pz=0,*eic_rich_vx=0,*eic_rich_vy=0,*eic_rich_vz=0,*eic_rich_mvx=0,*eic_rich_mvy=0,*eic_rich_mvz=0,*eic_rich_avg_t=0;
vector<int> *eic_rich_nsteps=0;
vector<double> *eic_rich_in_x=0,*eic_rich_in_y=0,*eic_rich_in_z=0,*eic_rich_in_px=0,*eic_rich_in_py=0,*eic_rich_in_pz=0,*eic_rich_in_t=0,*eic_rich_out_x=0,*eic_rich_out_y=0,*eic_rich_out_z=0,*eic_rich_out_px=0,*eic_rich_out_py=0,*eic_rich_out_pz=0,*eic_rich_out_t=0;

tree_eic_rich->SetBranchAddress("hitn",&eic_rich_hitn);
tree_eic_rich->SetBranchAddress("id",&eic_rich_id);
tree_eic_rich->SetBranchAddress("pid",&eic_rich_pid);
tree_eic_rich->SetBranchAddress("mpid",&eic_rich_mpid);
tree_eic_rich->SetBranchAddress("tid",&eic_rich_tid);
tree_eic_rich->SetBranchAddress("mtid",&eic_rich_mtid);
tree_eic_rich->SetBranchAddress("otid",&eic_rich_otid);
tree_eic_rich->SetBranchAddress("trackE",&eic_rich_trackE);
tree_eic_rich->SetBranchAddress("totEdep",&eic_rich_totEdep);
tree_eic_rich->SetBranchAddress("avg_x",&eic_rich_avg_x);
tree_eic_rich->SetBranchAddress("avg_y",&eic_rich_avg_y);
tree_eic_rich->SetBranchAddress("avg_z",&eic_rich_avg_z);
tree_eic_rich->SetBranchAddress("avg_lx",&eic_rich_avg_lx);
tree_eic_rich->SetBranchAddress("avg_ly",&eic_rich_avg_ly);
tree_eic_rich->SetBranchAddress("avg_lz",&eic_rich_avg_lz);
tree_eic_rich->SetBranchAddress("px",&eic_rich_px);
tree_eic_rich->SetBranchAddress("py",&eic_rich_py);
tree_eic_rich->SetBranchAddress("pz",&eic_rich_pz);
tree_eic_rich->SetBranchAddress("vx",&eic_rich_vx);
tree_eic_rich->SetBranchAddress("vy",&eic_rich_vy);
tree_eic_rich->SetBranchAddress("vz",&eic_rich_vz);
tree_eic_rich->SetBranchAddress("mvx",&eic_rich_mvx);
tree_eic_rich->SetBranchAddress("mvy",&eic_rich_mvy);
tree_eic_rich->SetBranchAddress("mvz",&eic_rich_mvz);
tree_eic_rich->SetBranchAddress("avg_t",&eic_rich_avg_t);
tree_eic_rich->SetBranchAddress("nsteps",&eic_rich_nsteps);
tree_eic_rich->SetBranchAddress("in_x",&eic_rich_in_x);
tree_eic_rich->SetBranchAddress("in_y",&eic_rich_in_y);
tree_eic_rich->SetBranchAddress("in_z",&eic_rich_in_z);
tree_eic_rich->SetBranchAddress("in_px",&eic_rich_in_px);
tree_eic_rich->SetBranchAddress("in_py",&eic_rich_in_py);
tree_eic_rich->SetBranchAddress("in_pz",&eic_rich_in_pz);
tree_eic_rich->SetBranchAddress("in_t",&eic_rich_in_t);
tree_eic_rich->SetBranchAddress("out_x",&eic_rich_out_x);
tree_eic_rich->SetBranchAddress("out_y",&eic_rich_out_y);
tree_eic_rich->SetBranchAddress("out_z",&eic_rich_out_z);
tree_eic_rich->SetBranchAddress("out_px",&eic_rich_out_px);
tree_eic_rich->SetBranchAddress("out_py",&eic_rich_out_py);
tree_eic_rich->SetBranchAddress("out_pz",&eic_rich_out_pz);
tree_eic_rich->SetBranchAddress("out_t",&eic_rich_out_t);

int nevent = (int)tree_generated->GetEntries();
int nselected = 0;
cout << "nevent " << nevent << endl;

for (Int_t i=0;i<nevent;i++) { 
//   cout << i << "\r";
//   cout << i << "\n";

  tree_header->GetEntry(i);
  
  tree_generated->GetEntry(i);  
  
  int pid_gen=0;
  double theta_gen=0,phi_gen=0,p_gen=0,px_gen=0,py_gen=0,pz_gen=0,vx_gen=0,vy_gen=0,vz_gen=0;      
  for (int j=0;j<gen_pid->size();j++) {
//       cout << gen_pid->at(j) << " " << gen_px->at(j) << " " << gen_py->at(j) << " " << gen_pz->at(j) << " " << gen_vx->at(j) << " " << gen_vy->at(j) << " " << gen_vz->at(j) << endl; 
      pid_gen=gen_pid->at(j);
      px_gen=gen_px->at(j)/1e3;    	//in MeV, convert to GeV
      py_gen=gen_py->at(j)/1e3;		//in MeV, convert to GeV
      pz_gen=gen_pz->at(j)/1e3;      	//in MeV, convert to GeV
      vx_gen=gen_vx->at(j)/1e1;    	//in mm, convert to cm
      vy_gen=gen_vy->at(j)/1e1;		//in mm, convert to cm
      vz_gen=gen_vz->at(j)/1e1;     	//in mm, convert to cm
      p_gen=sqrt(px_gen*px_gen+py_gen*py_gen+pz_gen*pz_gen);
      theta_gen=acos(pz_gen/p_gen)*DEG;  	//in deg
      phi_gen=atan2(py_gen,px_gen)*DEG;     	//in deg                
  }  
  
    tree_eic_rich->GetEntry(i);    
    
    for (Int_t j=0;j<eic_rich_hitn->size();j++) {
//             cout << "eic_rich " << j << " !!! " << eic_rich_id->at(j) << " " << eic_rich_pid->at(j) << " " << eic_rich_mpid->at(j) << " " << eic_rich_tid->at(j) << " " << eic_rich_mtid->at(j) << " " << eic_rich_trackE->at(j) << " " << eic_rich_totEdep->at(j) << " " << eic_rich_avg_x->at(j) << " " << eic_rich_avg_y->at(j) << " " << eic_rich_avg_z->at(j) << " " << eic_rich_avg_lx->at(j) << " " << eic_rich_avg_ly->at(j) << " " << eic_rich_avg_lz->at(j) << " " << eic_rich_px->at(j) << " " << eic_rich_py->at(j) << " " << eic_rich_pz->at(j) << " " << eic_rich_vx->at(j) << " " << eic_rich_vy->at(j) << " " << eic_rich_vz->at(j) << " " << eic_rich_mvx->at(j) << " " << eic_rich_mvy->at(j) << " " << eic_rich_mvz->at(j) << " " << eic_rich_avg_t->at(j) << endl;           
    
    int detector_ID=eic_rich_id->at(j)/1000000;  // 2 for mRICH
    int subdetector_ID=(eic_rich_id->at(j)%1000000)/1000; //module number 1 - max
    int subsubdetector_ID=((eic_rich_id->at(j)%1000000)%1000)/100;  //hit on PMT 1-4, hit in aerogel 0
    
    if (eic_rich_pid->at(j)==0) { // optical photon has pid 0
    cout << eic_rich_id->at(j) << " " << detector_ID << " " << subdetector_ID << " " << subsubdetector_ID << endl;  
    }
        
//     htotEdep[detector_ID-1][subdetector_ID]->Fill(eic_rich_totEdep->at(j));

    }
     
}
file->Close();

// TCanvas *c_totEdep = new TCanvas("totEdep","totEdep",1800,800);
// c_totEdep->Divide(8,3);
// for(int i=0;i<8;i++){
// for(int j=0;j<3;j++){
// c_totEdep->cd(j*8+i+1);
// gPad->SetLogy(1);
// htotEdep[i][j]->Draw();
// }
// }	

}
