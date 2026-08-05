import { useState } from "react";
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Eye, Layers, ZoomIn, ZoomOut, Maximize2, Activity, CheckCircle2, ChevronLeft, ChevronRight } from "lucide-react";
import { motion, AnimatePresence } from "framer-motion";

export const PATIENT_SCAN_IMAGES = [
  {
    id: "sagittal-compartments",
    title: "Sagittal Anatomical Airway Compartments",
    subtitle: "RP/RG Compartment & Landmark Distance Analysis (32.40mm / 14.01mm / 10.40mm)",
    url: "/scans/scan-sagittal-compartments.jpg",
    type: "Sagittal CBCT",
    badge: "Compartment Landmarks",
  },
  {
    id: "sagittal-levels",
    title: "Upper & Pharyngeal Airway Segmentation",
    subtitle: "C1-F, C2-F, C3-F Cervical Spine Boundary Marking",
    url: "/scans/scan-sagittal-levels.jpg",
    type: "Level Segmentation",
    badge: "Anatomical Levels",
  },
  {
    id: "3d-volume",
    title: "3D Airway Volume Heatmap & Constriction Rendering",
    subtitle: "Airway Volume: 14.3 cm³ | Min Area: 50.3 mm² | AP: 5.1 mm",
    url: "/scans/scan-3d-volume.jpg",
    type: "3D Volumetric",
    badge: "3D Heatmap",
  },
  {
    id: "axial-crosssection",
    title: "Axial Cross-Section Airway Area Measurement",
    subtitle: "Min Cross-Section Area: 368.10 mm² | Transverse Width: 30.03 mm",
    url: "/scans/scan-axial-crosssection.jpg",
    type: "Axial View",
    badge: "Min Constriction Area",
  },
];

interface ScanViewerModalProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  patientName?: string;
  scanDate?: string;
}

export function ScanViewerModal({
  open,
  onOpenChange,
  patientName = "Patient Scan",
  scanDate = "Recent CBCT",
}: ScanViewerModalProps) {
  const [activeTab, setActiveTab] = useState(0);
  const [zoom, setZoom] = useState(1);

  const activeImage = PATIENT_SCAN_IMAGES[activeTab];

  const handleNext = () => {
    setActiveTab((prev) => (prev + 1) % PATIENT_SCAN_IMAGES.length);
    setZoom(1);
  };

  const handlePrev = () => {
    setActiveTab((prev) => (prev - 1 + PATIENT_SCAN_IMAGES.length) % PATIENT_SCAN_IMAGES.length);
    setZoom(1);
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-4xl max-h-[90vh] flex flex-col p-0 overflow-hidden rounded-2xl bg-slate-950 border-slate-800 text-white">
        <DialogHeader className="p-4 px-6 border-b border-slate-800 bg-slate-900/90 flex flex-row items-center justify-between">
          <div>
            <DialogTitle className="font-display text-lg font-bold flex items-center gap-2 text-white">
              <Eye className="w-5 h-5 text-teal-400" />
              CBCT Airway Scan Viewer — {patientName}
            </DialogTitle>
            <p className="text-xs text-slate-400 mt-0.5">
              Acquisition Date: {scanDate} • Clinical Diagnostic Series
            </p>
          </div>
        </DialogHeader>

        {/* View Mode Selector Tabs */}
        <div className="flex items-center justify-between px-6 py-2 bg-slate-900 border-b border-slate-800 overflow-x-auto gap-2">
          <div className="flex items-center gap-1.5 overflow-x-auto py-1">
            {PATIENT_SCAN_IMAGES.map((img, idx) => (
              <button
                key={img.id}
                onClick={() => {
                  setActiveTab(idx);
                  setZoom(1);
                }}
                className={`px-3 py-1.5 rounded-lg text-xs font-semibold transition-all shrink-0 flex items-center gap-1.5 ${
                  activeTab === idx
                    ? "bg-teal-500 text-slate-950 shadow-md shadow-teal-500/20"
                    : "bg-slate-800/80 text-slate-300 hover:bg-slate-800 hover:text-white"
                }`}
              >
                <Layers className="w-3.5 h-3.5" />
                {img.type}
              </button>
            ))}
          </div>

          {/* Zoom controls */}
          <div className="flex items-center gap-1 bg-slate-800/60 p-1 rounded-lg shrink-0">
            <Button
              size="icon"
              variant="ghost"
              className="w-7 h-7 text-slate-300 hover:text-white hover:bg-slate-700"
              onClick={() => setZoom((z) => Math.max(0.8, z - 0.2))}
            >
              <ZoomOut className="w-3.5 h-3.5" />
            </Button>
            <span className="text-[11px] font-mono text-slate-300 w-10 text-center">
              {Math.round(zoom * 100)}%
            </span>
            <Button
              size="icon"
              variant="ghost"
              className="w-7 h-7 text-slate-300 hover:text-white hover:bg-slate-700"
              onClick={() => setZoom((z) => Math.min(2.5, z + 0.2))}
            >
              <ZoomIn className="w-3.5 h-3.5" />
            </Button>
            <Button
              size="icon"
              variant="ghost"
              className="w-7 h-7 text-slate-300 hover:text-white hover:bg-slate-700 ml-1"
              onClick={() => setZoom(1)}
              title="Reset Zoom"
            >
              <Maximize2 className="w-3.5 h-3.5" />
            </Button>
          </div>
        </div>

        {/* Scan Image Container */}
        <div className="flex-1 bg-black relative flex items-center justify-center min-h-[380px] max-h-[520px] overflow-hidden group">
          <AnimatePresence mode="wait">
            <motion.div
              key={activeImage.id}
              initial={{ opacity: 0, scale: 0.97 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 0.97 }}
              transition={{ duration: 0.2 }}
              className="w-full h-full flex items-center justify-center p-4 relative"
            >
              <img
                src={activeImage.url}
                alt={activeImage.title}
                className="max-h-full max-w-full object-contain rounded-lg shadow-2xl transition-transform duration-200"
                style={{ transform: `scale(${zoom})` }}
              />
            </motion.div>
          </AnimatePresence>

          {/* Navigation Arrows */}
          <button
            onClick={handlePrev}
            className="absolute left-3 top-1/2 -translate-y-1/2 w-9 h-9 rounded-full bg-slate-900/80 text-white flex items-center justify-center border border-slate-700/60 hover:bg-teal-500 hover:text-slate-950 transition-all opacity-70 group-hover:opacity-100"
          >
            <ChevronLeft className="w-5 h-5" />
          </button>
          <button
            onClick={handleNext}
            className="absolute right-3 top-1/2 -translate-y-1/2 w-9 h-9 rounded-full bg-slate-900/80 text-white flex items-center justify-center border border-slate-700/60 hover:bg-teal-500 hover:text-slate-950 transition-all opacity-70 group-hover:opacity-100"
          >
            <ChevronRight className="w-5 h-5" />
          </button>
        </div>

        {/* Image Metadata Footer */}
        <div className="p-4 px-6 bg-slate-900 border-t border-slate-800 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3">
          <div>
            <div className="flex items-center gap-2">
              <span className="px-2 py-0.5 rounded text-[10px] font-bold uppercase tracking-wider bg-teal-500/20 text-teal-400 border border-teal-500/30">
                {activeImage.badge}
              </span>
              <h4 className="font-display font-bold text-sm text-white">
                {activeImage.title}
              </h4>
            </div>
            <p className="text-xs text-slate-400 mt-1">
              {activeImage.subtitle}
            </p>
          </div>

          <div className="flex items-center gap-2 shrink-0">
            <span className="text-[11px] font-semibold text-emerald-400 flex items-center gap-1 bg-emerald-500/10 px-2.5 py-1 rounded-full border border-emerald-500/20">
              <CheckCircle2 className="w-3.5 h-3.5" /> High Resolution CBCT
            </span>
          </div>
        </div>
      </DialogContent>
    </Dialog>
  );
}
