import { Link } from "react-router-dom";
import { Modal, ModalBody, ModalContent, ModalFooter, ModalHeader, ModalOverlay } from "../components/common/Modal";

export function CreateMealPlan() {
  return (
    <Modal isOpen onClose={() => {}} size="md" isCentered>
      <ModalOverlay />
      <ModalContent>
        <ModalHeader>Start Organizing your group dinner</ModalHeader>
        <ModalBody>
          <p className="text-gray-600 mb-4">
            {/* You need to be signed in to write a review for {restaurantName}. */}
          </p>
        </ModalBody>
        <ModalFooter>
          <button className="btn-secondary">
            Continue
          </button>
        </ModalFooter>
      </ModalContent>
    </Modal>
  );
}
