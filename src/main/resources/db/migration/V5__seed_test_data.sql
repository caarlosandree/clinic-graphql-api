-- Migration: V5__seed_test_data.sql
-- Description: Seed data for testing purposes
-- This migration inserts realistic test data for clinics, procedures, professionals and appointments
-- All UUIDs are fixed to facilitate testing
-- All relationships are validated to ensure data integrity

-- ============================================
-- CLINICS (5 clinics)
-- ============================================

INSERT INTO clinics (id, name, cnpj, phone, address, created_at, updated_at) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'Clínica Estética Bella Donna', '12345678000190', '(11) 3456-7890', 'Av. Paulista, 1000 - São Paulo, SP', NOW(), NOW()),
('550e8400-e29b-41d4-a716-446655440002', 'Centro de Beleza Renovar', '23456789000191', '(21) 2345-6789', 'Rua da Assembleia, 500 - Rio de Janeiro, RJ', NOW(), NOW()),
('550e8400-e29b-41d4-a716-446655440003', 'Estética Vida Nova', '34567890000192', '(31) 3456-7890', 'Av. Afonso Pena, 200 - Belo Horizonte, MG', NOW(), NOW()),
('550e8400-e29b-41d4-a716-446655440004', 'Clínica Harmonia', '45678901000193', '(41) 2345-6789', 'Rua XV de Novembro, 800 - Curitiba, PR', NOW(), NOW()),
('550e8400-e29b-41d4-a716-446655440005', 'Spa & Estética Serenity', '56789012000194', '(51) 3456-7890', 'Av. Ipiranga, 1500 - Porto Alegre, RS', NOW(), NOW());

-- ============================================
-- PROCEDURES (15 procedures - 3 per clinic)
-- ============================================

-- Procedures for Clínica Estética Bella Donna (ID: 550e8400-e29b-41d4-a716-446655440001)
INSERT INTO procedures (id, name, description, duration_minutes, price, clinic_id, created_at, updated_at) VALUES
('660e8400-e29b-41d4-a716-446655440101', 'Limpeza de Pele Profunda', 'Limpeza de pele com extração de cravos e hidratação', 60, 150.00, '550e8400-e29b-41d4-a716-446655440001', NOW(), NOW()),
('660e8400-e29b-41d4-a716-446655440102', 'Botox Facial', 'Aplicação de toxina botulínica para suavizar linhas de expressão', 45, 800.00, '550e8400-e29b-41d4-a716-446655440001', NOW(), NOW()),
('660e8400-e29b-41d4-a716-446655440103', 'Preenchimento Facial', 'Preenchimento com ácido hialurônico para volume e contorno', 60, 1200.00, '550e8400-e29b-41d4-a716-446655440001', NOW(), NOW());

-- Procedures for Centro de Beleza Renovar (ID: 550e8400-e29b-41d4-a716-446655440002)
INSERT INTO procedures (id, name, description, duration_minutes, price, clinic_id, created_at, updated_at) VALUES
('660e8400-e29b-41d4-a716-446655440201', 'Depilação a Laser', 'Depilação definitiva com laser em diversas áreas do corpo', 30, 250.00, '550e8400-e29b-41d4-a716-446655440002', NOW(), NOW()),
('660e8400-e29b-41d4-a716-446655440202', 'Drenagem Linfática', 'Massagem linfática para desintoxicação e redução de inchaço', 60, 200.00, '550e8400-e29b-41d4-a716-446655440002', NOW(), NOW()),
('660e8400-e29b-41d4-a716-446655440203', 'Peeling Químico', 'Esfoliação química para renovar a pele e tratar manchas', 45, 300.00, '550e8400-e29b-41d4-a716-446655440002', NOW(), NOW());

-- Procedures for Estética Vida Nova (ID: 550e8400-e29b-41d4-a716-446655440003)
INSERT INTO procedures (id, name, description, duration_minutes, price, clinic_id, created_at, updated_at) VALUES
('660e8400-e29b-41d4-a716-446655440301', 'Microagulhamento', 'Estimulação de colágeno com microagulhas para rejuvenescimento', 60, 450.00, '550e8400-e29b-41d4-a716-446655440003', NOW(), NOW()),
('660e8400-e29b-41d4-a716-446655440302', 'Design de Sobrancelhas', 'Modelagem e design de sobrancelhas com henna ou fio', 30, 80.00, '550e8400-e29b-41d4-a716-446655440003', NOW(), NOW()),
('660e8400-e29b-41d4-a716-446655440303', 'Massagem Relaxante', 'Massagem terapêutica para alívio de tensão e relaxamento', 60, 180.00, '550e8400-e29b-41d4-a716-446655440003', NOW(), NOW());

-- Procedures for Clínica Harmonia (ID: 550e8400-e29b-41d4-a716-446655440004)
INSERT INTO procedures (id, name, description, duration_minutes, price, clinic_id, created_at, updated_at) VALUES
('660e8400-e29b-41d4-a716-446655440401', 'Laser CO2 Fracionado', 'Tratamento a laser para cicatrizes e rejuvenescimento', 45, 1500.00, '550e8400-e29b-41d4-a716-446655440004', NOW(), NOW()),
('660e8400-e29b-41d4-a716-446655440402', 'Radiofrequência Facial', 'Estimulação de colágeno com radiofrequência para firmeza', 50, 350.00, '550e8400-e29b-41d4-a716-446655440004', NOW(), NOW()),
('660e8400-e29b-41d4-a716-446655440403', 'Luz Intensa Pulsada (IPL)', 'Tratamento para manchas, vasos e rejuvenescimento', 40, 280.00, '550e8400-e29b-41d4-a716-446655440004', NOW(), NOW());

-- Procedures for Spa & Estética Serenity (ID: 550e8400-e29b-41d4-a716-446655440005)
INSERT INTO procedures (id, name, description, duration_minutes, price, clinic_id, created_at, updated_at) VALUES
('660e8400-e29b-41d4-a716-446655440501', 'Spa Day Completo', 'Pacote completo com massagem, hidratação e cuidados faciais', 180, 500.00, '550e8400-e29b-41d4-a716-446655440005', NOW(), NOW()),
('660e8400-e29b-41d4-a716-446655440502', 'Hidratação Profunda', 'Hidratação facial com máscara e soro personalizado', 45, 120.00, '550e8400-e29b-41d4-a716-446655440005', NOW(), NOW()),
('660e8400-e29b-41d4-a716-446655440503', 'Banho de Espuma', 'Banho relaxante com espuma e óleos essenciais', 40, 90.00, '550e8400-e29b-41d4-a716-446655440005', NOW(), NOW());

-- ============================================
-- PROFESSIONALS (15 professionals - 3 per clinic)
-- ============================================

-- Professionals for Clínica Estética Bella Donna (ID: 550e8400-e29b-41d4-a716-446655440001)
INSERT INTO professionals (id, name, specialty, clinic_id, created_at, updated_at) VALUES
('770e8400-e29b-41d4-a716-446655440101', 'Dra. Ana Silva', 'Dermatologista', '550e8400-e29b-41d4-a716-446655440001', NOW(), NOW()),
('770e8400-e29b-41d4-a716-446655440102', 'Dra. Carla Oliveira', 'Esteticista', '550e8400-e29b-41d4-a716-446655440001', NOW(), NOW()),
('770e8400-e29b-41d4-a716-446655440103', 'Dr. Pedro Santos', 'Médico Plástico', '550e8400-e29b-41d4-a716-446655440001', NOW(), NOW());

-- Professionals for Centro de Beleza Renovar (ID: 550e8400-e29b-41d4-a716-446655440002)
INSERT INTO professionals (id, name, specialty, clinic_id, created_at, updated_at) VALUES
('770e8400-e29b-41d4-a716-446655440201', 'Dra. Mariana Costa', 'Esteticista', '550e8400-e29b-41d4-a716-446655440002', NOW(), NOW()),
('770e8400-e29b-41d4-a716-446655440202', 'Dr. Ricardo Lima', 'Dermatologista', '550e8400-e29b-41d4-a716-446655440002', NOW(), NOW()),
('770e8400-e29b-41d4-a716-446655440203', 'Dra. Fernanda Alves', 'Massoterapeuta', '550e8400-e29b-41d4-a716-446655440002', NOW(), NOW());

-- Professionals for Estética Vida Nova (ID: 550e8400-e29b-41d4-a716-446655440003)
INSERT INTO professionals (id, name, specialty, clinic_id, created_at, updated_at) VALUES
('770e8400-e29b-41d4-a716-446655440301', 'Dr. João Batista', 'Médico Plástico', '550e8400-e29b-41d4-a716-446655440003', NOW(), NOW()),
('770e8400-e29b-41d4-a716-446655440302', 'Dra. Beatriz Rocha', 'Esteticista', '550e8400-e29b-41d4-a716-446655440003', NOW(), NOW()),
('770e8400-e29b-41d4-a716-446655440303', 'Dr. Lucas Ferreira', 'Dermatologista', '550e8400-e29b-41d4-a716-446655440003', NOW(), NOW());

-- Professionals for Clínica Harmonia (ID: 550e8400-e29b-41d4-a716-446655440004)
INSERT INTO professionals (id, name, specialty, clinic_id, created_at, updated_at) VALUES
('770e8400-e29b-41d4-a716-446655440401', 'Dra. Julia Mendes', 'Dermatologista', '550e8400-e29b-41d4-a716-446655440004', NOW(), NOW()),
('770e8400-e29b-41d4-a716-446655440402', 'Dr. Marcos Pereira', 'Médico Plástico', '550e8400-e29b-41d4-a716-446655440004', NOW(), NOW()),
('770e8400-e29b-41d4-a716-446655440403', 'Dra. Amanda Souza', 'Esteticista', '550e8400-e29b-41d4-a716-446655440004', NOW(), NOW());

-- Professionals for Spa & Estética Serenity (ID: 550e8400-e29b-41d4-a716-446655440005)
INSERT INTO professionals (id, name, specialty, clinic_id, created_at, updated_at) VALUES
('770e8400-e29b-41d4-a716-446655440501', 'Dra. Camila Dias', 'Massoterapeuta', '550e8400-e29b-41d4-a716-446655440005', NOW(), NOW()),
('770e8400-e29b-41d4-a716-446655440502', 'Dr. Bruno Martins', 'Esteticista', '550e8400-e29b-41d4-a716-446655440005', NOW(), NOW()),
('770e8400-e29b-41d4-a716-446655440503', 'Dra. Gabriela Nunes', 'Dermatologista', '550e8400-e29b-41d4-a716-446655440005', NOW(), NOW());

-- ============================================
-- APPOINTMENTS (30 appointments - 6 per clinic)
-- All appointments use procedure and professional from the same clinic
-- Dates are in the future (starting from tomorrow)
-- Status varies: SCHEDULED, CANCELLED, FINISHED
-- ============================================

-- Appointments for Clínica Estética Bella Donna (ID: 550e8400-e29b-41d4-a716-446655440001)
INSERT INTO appointments (id, patient_name, patient_phone, scheduled_at, status, clinic_id, procedure_id, professional_id, created_at, updated_at) VALUES
('880e8400-e29b-41d4-a716-446655440101', 'Maria Oliveira', '(11) 98765-4321', NOW() + INTERVAL '1 day' + INTERVAL '10:00', 'SCHEDULED', '550e8400-e29b-41d4-a716-446655440001', '660e8400-e29b-41d4-a716-446655440101', '770e8400-e29b-41d4-a716-446655440101', NOW(), NOW()),
('880e8400-e29b-41d4-a716-446655440102', 'João Silva', '(11) 91234-5678', NOW() + INTERVAL '2 days' + INTERVAL '14:00', 'SCHEDULED', '550e8400-e29b-41d4-a716-446655440001', '660e8400-e29b-41d4-a716-446655440102', '770e8400-e29b-41d4-a716-446655440103', NOW(), NOW()),
('880e8400-e29b-41d4-a716-446655440103', 'Ana Costa', '(11) 92345-6789', NOW() + INTERVAL '3 days' + INTERVAL '09:00', 'CANCELLED', '550e8400-e29b-41d4-a716-446655440001', '660e8400-e29b-41d4-a716-446655440103', '770e8400-e29b-41d4-a716-446655440102', NOW(), NOW()),
('880e8400-e29b-41d4-a716-446655440104', 'Carlos Santos', '(11) 93456-7890', NOW() + INTERVAL '5 days' + INTERVAL '16:00', 'SCHEDULED', '550e8400-e29b-41d4-a716-446655440001', '660e8400-e29b-41d4-a716-446655440101', '770e8400-e29b-41d4-a716-446655440101', NOW(), NOW()),
('880e8400-e29b-41d4-a716-446655440105', 'Fernanda Lima', '(11) 94567-8901', NOW() + INTERVAL '7 days' + INTERVAL '11:00', 'FINISHED', '550e8400-e29b-41d4-a716-446655440001', '660e8400-e29b-41d4-a716-446655440102', '770e8400-e29b-41d4-a716-446655440103', NOW(), NOW()),
('880e8400-e29b-41d4-a716-446655440106', 'Ricardo Alves', '(11) 95678-9012', NOW() + INTERVAL '10 days' + INTERVAL '15:00', 'SCHEDULED', '550e8400-e29b-41d4-a716-446655440001', '660e8400-e29b-41d4-a716-446655440103', '770e8400-e29b-41d4-a716-446655440102', NOW(), NOW());

-- Appointments for Centro de Beleza Renovar (ID: 550e8400-e29b-41d4-a716-446655440002)
INSERT INTO appointments (id, patient_name, patient_phone, scheduled_at, status, clinic_id, procedure_id, professional_id, created_at, updated_at) VALUES
('880e8400-e29b-41d4-a716-446655440201', 'Patrícia Rocha', '(21) 98765-4321', NOW() + INTERVAL '1 day' + INTERVAL '09:30', 'SCHEDULED', '550e8400-e29b-41d4-a716-446655440002', '660e8400-e29b-41d4-a716-446655440201', '770e8400-e29b-41d4-a716-446655440201', NOW(), NOW()),
('880e8400-e29b-41d4-a716-446655440202', 'Roberto Mendes', '(21) 91234-5678', NOW() + INTERVAL '2 days' + INTERVAL '13:00', 'FINISHED', '550e8400-e29b-41d4-a716-446655440002', '660e8400-e29b-41d4-a716-446655440202', '770e8400-e29b-41d4-a716-446655440203', NOW(), NOW()),
('880e8400-e29b-41d4-a716-446655440203', 'Luiza Pereira', '(21) 92345-6789', NOW() + INTERVAL '4 days' + INTERVAL '10:30', 'SCHEDULED', '550e8400-e29b-41d4-a716-446655440002', '660e8400-e29b-41d4-a716-446655440203', '770e8400-e29b-41d4-a716-446655440202', NOW(), NOW()),
('880e8400-e29b-41d4-a716-446655440204', 'André Costa', '(21) 93456-7890', NOW() + INTERVAL '6 days' + INTERVAL '15:30', 'CANCELLED', '550e8400-e29b-41d4-a716-446655440002', '660e8400-e29b-41d4-a716-446655440201', '770e8400-e29b-41d4-a716-446655440201', NOW(), NOW()),
('880e8400-e29b-41d4-a716-446655440205', 'Beatriz Ferreira', '(21) 94567-8901', NOW() + INTERVAL '8 days' + INTERVAL '11:30', 'SCHEDULED', '550e8400-e29b-41d4-a716-446655440002', '660e8400-e29b-41d4-a716-446655440202', '770e8400-e29b-41d4-a716-446655440203', NOW(), NOW()),
('880e8400-e29b-41d4-a716-446655440206', 'Felipe Nunes', '(21) 95678-9012', NOW() + INTERVAL '12 days' + INTERVAL '14:30', 'SCHEDULED', '550e8400-e29b-41d4-a716-446655440002', '660e8400-e29b-41d4-a716-446655440203', '770e8400-e29b-41d4-a716-446655440202', NOW(), NOW());

-- Appointments for Estética Vida Nova (ID: 550e8400-e29b-41d4-a716-446655440003)
INSERT INTO appointments (id, patient_name, patient_phone, scheduled_at, status, clinic_id, procedure_id, professional_id, created_at, updated_at) VALUES
('880e8400-e29b-41d4-a716-446655440301', 'Juliana Dias', '(31) 98765-4321', NOW() + INTERVAL '1 day' + INTERVAL '08:00', 'SCHEDULED', '550e8400-e29b-41d4-a716-446655440003', '660e8400-e29b-41d4-a716-446655440301', '770e8400-e29b-41d4-a716-446655440301', NOW(), NOW()),
('880e8400-e29b-41d4-a716-446655440302', 'Thiago Martins', '(31) 91234-5678', NOW() + INTERVAL '3 days' + INTERVAL '10:00', 'CANCELLED', '550e8400-e29b-41d4-a716-446655440003', '660e8400-e29b-41d4-a716-446655440302', '770e8400-e29b-41d4-a716-446655440302', NOW(), NOW()),
('880e8400-e29b-41d4-a716-446655440303', 'Carla Barbosa', '(31) 92345-6789', NOW() + INTERVAL '5 days' + INTERVAL '14:00', 'SCHEDULED', '550e8400-e29b-41d4-a716-446655440003', '660e8400-e29b-41d4-a716-446655440303', '770e8400-e29b-41d4-a716-446655440303', NOW(), NOW()),
('880e8400-e29b-41d4-a716-446655440304', 'Gustavo Moreira', '(31) 93456-7890', NOW() + INTERVAL '7 days' + INTERVAL '09:00', 'FINISHED', '550e8400-e29b-41d4-a716-446655440003', '660e8400-e29b-41d4-a716-446655440301', '770e8400-e29b-41d4-a716-446655440301', NOW(), NOW()),
('880e8400-e29b-41d4-a716-446655440305', 'Larissa Gomes', '(31) 94567-8901', NOW() + INTERVAL '9 days' + INTERVAL '16:00', 'SCHEDULED', '550e8400-e29b-41d4-a716-446655440003', '660e8400-e29b-41d4-a716-446655440302', '770e8400-e29b-41d4-a716-446655440302', NOW(), NOW()),
('880e8400-e29b-41d4-a716-446655440306', 'Bruno Araújo', '(31) 95678-9012', NOW() + INTERVAL '14 days' + INTERVAL '11:00', 'SCHEDULED', '550e8400-e29b-41d4-a716-446655440003', '660e8400-e29b-41d4-a716-446655440303', '770e8400-e29b-41d4-a716-446655440303', NOW(), NOW());

-- Appointments for Clínica Harmonia (ID: 550e8400-e29b-41d4-a716-446655440004)
INSERT INTO appointments (id, patient_name, patient_phone, scheduled_at, status, clinic_id, procedure_id, professional_id, created_at, updated_at) VALUES
('880e8400-e29b-41d4-a716-446655440401', 'Mariana Cardoso', '(41) 98765-4321', NOW() + INTERVAL '2 days' + INTERVAL '13:00', 'SCHEDULED', '550e8400-e29b-41d4-a716-446655440004', '660e8400-e29b-41d4-a716-446655440401', '770e8400-e29b-41d4-a716-446655440401', NOW(), NOW()),
('880e8400-e29b-41d4-a716-446655440402', 'Leonardo Vieira', '(41) 91234-5678', NOW() + INTERVAL '4 days' + INTERVAL '10:00', 'FINISHED', '550e8400-e29b-41d4-a716-446655440004', '660e8400-e29b-41d4-a716-446655440402', '770e8400-e29b-41d4-a716-446655440402', NOW(), NOW()),
('880e8400-e29b-41d4-a716-446655440403', 'Isabela Ribeiro', '(41) 92345-6789', NOW() + INTERVAL '6 days' + INTERVAL '15:00', 'SCHEDULED', '550e8400-e29b-41d4-a716-446655440004', '660e8400-e29b-41d4-a716-446655440403', '770e8400-e29b-41d4-a716-446655440403', NOW(), NOW()),
('880e8400-e29b-41d4-a716-446655440404', 'Rodrigo Castro', '(41) 93456-7890', NOW() + INTERVAL '8 days' + INTERVAL '09:00', 'CANCELLED', '550e8400-e29b-41d4-a716-446655440004', '660e8400-e29b-41d4-a716-446655440401', '770e8400-e29b-41d4-a716-446655440401', NOW(), NOW()),
('880e8400-e29b-41d4-a716-446655440405', 'Amanda Pinto', '(41) 94567-8901', NOW() + INTERVAL '11 days' + INTERVAL '14:00', 'SCHEDULED', '550e8400-e29b-41d4-a716-446655440004', '660e8400-e29b-41d4-a716-446655440402', '770e8400-e29b-41d4-a716-446655440402', NOW(), NOW()),
('880e8400-e29b-41d4-a716-446655440406', 'Diego Correia', '(41) 95678-9012', NOW() + INTERVAL '15 days' + INTERVAL '11:00', 'SCHEDULED', '550e8400-e29b-41d4-a716-446655440004', '660e8400-e29b-41d4-a716-446655440403', '770e8400-e29b-41d4-a716-446655440403', NOW(), NOW());

-- Appointments for Spa & Estética Serenity (ID: 550e8400-e29b-41d4-a716-446655440005)
INSERT INTO appointments (id, patient_name, patient_phone, scheduled_at, status, clinic_id, procedure_id, professional_id, created_at, updated_at) VALUES
('880e8400-e29b-41d4-a716-446655440501', 'Vanessa Farias', '(51) 98765-4321', NOW() + INTERVAL '1 day' + INTERVAL '10:00', 'SCHEDULED', '550e8400-e29b-41d4-a716-446655440005', '660e8400-e29b-41d4-a716-446655440501', '770e8400-e29b-41d4-a716-446655440501', NOW(), NOW()),
('880e8400-e29b-41d4-a716-446655440502', 'Eduardo Brandão', '(51) 91234-5678', NOW() + INTERVAL '3 days' + INTERVAL '14:00', 'FINISHED', '550e8400-e29b-41d4-a716-446655440005', '660e8400-e29b-41d4-a716-446655440502', '770e8400-e29b-41d4-a716-446655440502', NOW(), NOW()),
('880e8400-e29b-41d4-a716-446655440503', 'Renata Lourenço', '(51) 92345-6789', NOW() + INTERVAL '5 days' + INTERVAL '09:00', 'CANCELLED', '550e8400-e29b-41d4-a716-446655440005', '660e8400-e29b-41d4-a716-446655440503', '770e8400-e29b-41d4-a716-446655440503', NOW(), NOW()),
('880e8400-e29b-41d4-a716-446655440504', 'Lucas Neves', '(51) 93456-7890', NOW() + INTERVAL '7 days' + INTERVAL '16:00', 'SCHEDULED', '550e8400-e29b-41d4-a716-446655440005', '660e8400-e29b-41d4-a716-446655440501', '770e8400-e29b-41d4-a716-446655440501', NOW(), NOW()),
('880e8400-e29b-41d4-a716-446655440505', 'Camila Salgado', '(51) 94567-8901', NOW() + INTERVAL '10 days' + INTERVAL '11:00', 'SCHEDULED', '550e8400-e29b-41d4-a716-446655440005', '660e8400-e29b-41d4-a716-446655440502', '770e8400-e29b-41d4-a716-446655440502', NOW(), NOW()),
('880e8400-e29b-41d4-a716-446655440506', 'Mateus Vasconcelos', '(51) 95678-9012', NOW() + INTERVAL '13 days' + INTERVAL '15:00', 'SCHEDULED', '550e8400-e29b-41d4-a716-446655440005', '660e8400-e29b-41d4-a716-446655440503', '770e8400-e29b-41d4-a716-446655440503', NOW(), NOW());
